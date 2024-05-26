class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhooks]

  def link_accounts
    unless user_signed_in?
      render json: {error: "Unauthorized"}, status: :unauthorized
    end

    session = Stripe::FinancialConnections::Session.create({
      account_holder: {
        type: "customer",
        customer: current_user.stripe_customer_id
      },
      permissions: %w[balances transactions],
    })
    render json: {client_secret: session.client_secret}
  end

  def webhooks
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, webhook_endpoint_secret
      )
    rescue JSON::ParserError => e
      # Invalid payload
      logger.error("received invalid webhook event: #{e.message}")
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      logger.error("error verifying webhook signature: #{e.message}")
      return head :bad_request
    end

    object = event.data.object
    case event.type
    when "financial_connections.account.created"
      user = User.where(stripe_customer_id: object.account_holder.customer).first

      unless user.present?
        logger.warn(
          "couldn't find user with stripe customer ID: #{object.account_holder.customer}, skipping event"
        )
        return head :ok
      end

      account = FinancialAccount.new(
        user_id: user.id,
        institution_name: object.institution_name,
        category: object.category,
        subcategory: object.subcategory,
        last4: object.last4,
        stripe_financial_connections_account_id: object.id,
      )
      account.save!

      # Manually fetch balance/transactions after account is created, so we guarantee the account
      # exists in the DB
      Stripe::FinancialConnections::Account.refresh_account(object.id, features: ["balance"])
      Stripe::FinancialConnections::Account.subscribe(object.id, features: ["transactions"])
    when "financial_connections.account.refreshed_balance"
      account = FinancialAccount.find_by(stripe_financial_connections_account_id: object.id)

      unless account.present?
        logger.warn("account with stripe ID #{object.id} not found")
        return head :ok
      end

      account.update!(balance: object&.balance&.current&.usd)  # We only use USD for now
    when "financial_connections.account.refreshed_transactions"
      unless object.status == "active"
        logger.warn("account is not active, will not import transactions")
        return head :ok
      end

      import_transactions(object.id, object.transaction_refresh&.id)
    else
      logger.warn("unhandled event type: #{event.type}")
    end

    head :ok
  end

  private
  def webhook_endpoint_secret
    if Rails.env.production?
      Rails.application.credentials.stripe.live_webhook_endpoint_secret!
    else
      Rails.application.credentials.stripe.test_webhook_endpoint_secret!
    end
  end

  def import_transactions(stripe_account_id, transaction_refresh)
    account = FinancialAccount.find_by(stripe_financial_connections_account_id: stripe_account_id)

    unless account.present?
      logger.warn("could not find account with stripe ID #{stripe_account_id}")
      return
    end

    if account.last_transaction_refresh == transaction_refresh
      logger.warn("account already refreshed")
      return
    end

    FinancialAccount.transaction do
      new_txns = create_transactions_from_stripe(account.id, stripe_account_id)
      Transaction.insert_all!(new_txns)
      logger.info("inserted #{new_txns.count} transactions")
      account.update!(last_transaction_refresh: transaction_refresh)
    end
  end

  def create_transactions_from_stripe(financial_account_id, stripe_account_id)
    new_txns = []

    transactions = Stripe::FinancialConnections::Transaction.list(
      account: stripe_account_id,
      limit: 50,
    )
    transactions.auto_paging_each do |txn|
      new_txns << transaction_from_stripe_transaction(financial_account_id, txn)
    end

    new_txns
  end

  def transaction_from_stripe_transaction(financial_account_id, txn)
    transaction = {
      financial_account_id: financial_account_id,
      amount: txn.amount,
      currency: txn.currency,
      description: txn.description,
      status: txn.status,
      stripe_transaction_id: txn.id,
    }

    if txn.status_transitions&.posted_at.present?
      transaction[:posted_at] = Time.at(txn.status_transitions.posted_at).utc
    else
      transaction[:posted_at] = nil
    end

    if txn.status_transitions&.void_at.present?
      transaction[:void_at] = Time.at(txn.status_transitions.void_at).utc
    else
      transaction[:void_at] = nil
    end

    if txn.transacted_at.present?
      transaction[:transacted_at] = Time.at(txn.transacted_at).utc
    else
      transaction[:transacted_at] = nil
    end

    transaction
  end
end
