class CreateSpendingCategoryRules < ActiveRecord::Migration[7.1]
  def change
    create_table :spending_category_rules, id: :uuid do |t|
      t.integer :spending_category
      t.string :pattern, null: false, index: { unique: true }
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
