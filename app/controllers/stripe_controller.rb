class StripeController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhooks]

  def link_accounts
    unless current_user.present?
      render json: {error: "Unauthorized"}, status: :unauthorized
    end

    session = Stripe::FinancialConnections::Session.create({
      account_holder: {
        type: "customer",
        customer: current_user.stripe_customer_id
      },
      permissions: ["balances", "transactions"]
    })
    render json: {client_secret: session.client_secret}
  end

  def webhooks
    payload = request.body.string
    event = nil

    begin
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
    rescue JSON::ParserError => e
      # Invalid payload
      logger.error("received invalid webhook event: #{e}")
      return head :bad_request
    end

    case event.type
    when "financial_connections.account.created"
      object = event.data.object
      user = User.where(stripe_customer_id: object.account_holder.customer).first

      unless user.present?
        logger.warn("couldn't find user with stripe customer ID: #{object.account_holder.customer}")
        return head :ok
      end

      balance = case object.balance&.type
      when "cash"
        object.balance.cash
      when "credit"
        object.balance.credit
      when nil
        nil
      else
        logger.warn("invalid balance type: #{object.balance.type}")
        nil
      end

      account = FinancialAccount.new(
        user_id: user.id,
        institution_name: object.institution_name,
        balance: balance,
        category: object.category,
        subcategory: object.subcategory,
        last4: object.last4,
        stripe_financial_connections_account_id: object.id,
      )

      account.save!

      # TODO: kick off job to fetch transactions
    else
      logger.warn("unsupported event type: #{event.type}")
    end

    head :ok
  end
end
