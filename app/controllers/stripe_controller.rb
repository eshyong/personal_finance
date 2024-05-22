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

    case event.type
    when "financial_connections.account.created"
      object = event.data.object
      user = User.where(stripe_customer_id: object.account_holder.customer).first

      unless user.present?
        logger.warn("couldn't find user with stripe customer ID: #{object.account_holder.customer}, skipping event")
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

      # TODO: kick off job to fetch balance/transactions data
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
end
