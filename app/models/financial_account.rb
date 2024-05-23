class FinancialAccount < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  before_destroy :disconnect_stripe_financial_connections_account

  def disconnect_stripe_financial_connections_account
    begin
      Stripe::FinancialConnections::Account.disconnect(stripe_financial_connections_account_id)
    rescue Stripe::InvalidRequestError
      # Account may have been deactivated already
    end
  end
end
