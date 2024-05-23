class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions, id: :uuid do |t|
      t.references :financial_account, null: false, foreign_key: true, type: :uuid
      t.bigint :amount
      t.string :currency
      t.string :description
      t.string :status
      t.string :stripe_transaction_id
      t.datetime :posted_at
      t.datetime :void_at
      t.datetime :transacted_at

      t.timestamps
    end

    add_index :transactions, :stripe_transaction_id, unique: true
  end
end
