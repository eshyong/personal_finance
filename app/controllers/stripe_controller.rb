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
      FinancialAccountService.create_from_stripe!(object)
    when "financial_connections.account.refreshed_balance"
      FinancialAccountService.update_balance!(object)
    when "financial_connections.account.refreshed_transactions"
      FinancialAccountService.import_transactions_from_stripe!(object)
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
