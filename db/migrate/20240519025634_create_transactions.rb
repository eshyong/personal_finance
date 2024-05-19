class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.date :posted_on
      t.string :description
      t.string :category
      t.string :direction
      t.string :transaction_type
      t.bigint :amount
      t.bigint :balance

      t.timestamps
    end
  end
end
