class AddLastTransactionRefreshToFinancialAccount < ActiveRecord::Migration[7.1]
  def change
    add_column :financial_accounts, :last_transaction_refresh, :string
  end
end
