class Transaction < ApplicationRecord
  belongs_to :financial_account

  def get_amount_in_dollars
    amount.nil? ? 0.0 : amount / 100.0
  end
end
