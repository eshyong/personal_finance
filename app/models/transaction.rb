class Transaction < ApplicationRecord
  belongs_to :financial_account

  def get_amount_in_dollars
    amount.nil? ? 0.0 : amount / 100.0
  end

  def format_transacted_at
    transacted_at.strftime("%b %-d, %Y")
  end

  def self.hash_from_stripe_object(financial_account_id, txn)
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
