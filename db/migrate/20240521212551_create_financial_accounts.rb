class CreateFinancialAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :financial_accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :institution_name
      t.bigint :balance
      t.string :category
      t.string :subcategory
      t.string :last4
      t.string :stripe_financial_connections_account_id

      t.timestamps
    end
  end
end
