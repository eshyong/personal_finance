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
    p event

    case event.type
    when "financial_connections.account.created"
      # create new accounts for each stripe account linked
    else
      return render json: {"error": "unsupported event type #{event.type}"}, status: :bad_request
    end

    head :ok
  end
end
