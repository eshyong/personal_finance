class Transaction < ApplicationRecord
  belongs_to :financial_account

  def get_amount_in_dollars
    amt = amount.nil? ? 0.0 : amount / 100.0
    format("%.2f", amt)
  end

  def format_transacted_at
    transacted_at.strftime("%b %-d, %Y")
  end
end
