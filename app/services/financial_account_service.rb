class FinancialAccountService
  class << self
    def create_from_stripe!(object)
      unless object.present?
        return logger.warn("#{caller_name}: stripe object must not be empty")
      end

      user = User.where(stripe_customer_id: object.account_holder.customer).first

      unless user.present?
        return logger.warn(
          "#{caller_name}: couldn't find user with stripe customer ID: " \
          "#{object.account_holder.customer}, skipping event"
        )
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

      # Manually fetch balance/transactions after account is saved, so we guarantee the account
      # exists in the DB when webhooks are received
      Stripe::FinancialConnections::Account.refresh_account(object.id, features: ["balance"])
      Stripe::FinancialConnections::Account.subscribe(object.id, features: ["transactions"])
    end

    def update_balance!(object)
      unless object.present?
        return logger.warn("#{caller_name}: stripe object must be present")
      end

      account = FinancialAccount.find_by(stripe_financial_connections_account_id: object.id)

      unless account.present?
        return logger.warn(
          "#{caller_name}: account with stripe ID #{object.id} not found"
        )
      end

      account.update!(balance: object.balance.current.usd)  # We only use USD for now
    end

    def import_transactions_from_stripe!(object)
      unless object.present?
        return logger.warn(
          "#{caller_name}: stripe object must not be empty"
        )
      end

      unless object.status == "active"
        return logger.warn("#{caller_name}: account is not active, will not import transactions")
      end

      account = FinancialAccount.find_by(stripe_financial_connections_account_id: object.id)

      unless account.present?
        return logger.warn("#{caller_name}: could not find account with stripe ID #{object.id}")
      end

      transaction_refresh = object.transaction_refresh.id
      if account.last_transaction_refresh == transaction_refresh
        return logger.warn("#{caller_name}: account already refreshed")
      end

      FinancialAccount.transaction do
        new_txns = create_transactions_from_stripe(account.id, object.id)
        Transaction.upsert_all(new_txns, unique_by: :stripe_transaction_id)
        logger.info("#{caller_name}: inserted #{new_txns.count} transactions")
        account.update!(last_transaction_refresh: transaction_refresh)
      end
    end

    private

    def create_transactions_from_stripe(financial_account_id, stripe_account_id)
      new_txns = []

      transactions = Stripe::FinancialConnections::Transaction.list(
        account: stripe_account_id,
        limit: 50,
      )
      transactions.auto_paging_each do |txn|
        new_txns << Transaction.hash_from_stripe_object(financial_account_id, txn)
      end

      new_txns
    end

    def caller_name
      "#{self}##{caller_locations(1,1)[0].label}"
    end

    def logger
      Rails.logger
    end
  end
end
