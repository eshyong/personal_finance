class CreateFinancialAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :financial_accounts, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :institution_name
      t.bigint :balance
      t.string :category
      t.string :subcategory
      t.string :last4
      t.string :stripe_financial_connections_account_id

      t.timestamps
    end

    add_index :financial_accounts, :stripe_financial_connections_account_id, unique: true
  end
end
