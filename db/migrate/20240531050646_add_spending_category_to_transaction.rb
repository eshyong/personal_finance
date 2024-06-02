class AddSpendingCategoryToTransaction < ActiveRecord::Migration[7.1]
  def change
    add_column :transactions, :spending_category, :integer
  end
end
