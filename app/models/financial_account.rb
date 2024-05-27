class FinancialAccount < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  before_destroy :disconnect_stripe_financial_connections_account

  def get_balance_in_dollars
    balance.nil? ? 0.0 : balance / 100.0
  end

  def top_expenses_this_month(n = 5)
    transactions
      .where(transacted_at: Date.today.beginning_of_month..Date.today.end_of_month)
      .order(:amount)
      .limit(n)
  end

  def disconnect_stripe_financial_connections_account
    begin
      Stripe::FinancialConnections::Account.disconnect(stripe_financial_connections_account_id)
    rescue Stripe::InvalidRequestError
      # Account may have been deactivated already
    end
  end
end
