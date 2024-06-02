class SpendingCategoryRule < ApplicationRecord
  validates :spending_category, presence: true
  validates :pattern, presence: true

  enum :spending_category, Transaction::SPENDING_CATEGORIES

  belongs_to :user

  def applies_to_transaction?(txn)
    pattern_regexp.match?(txn.description)
  end

  def pattern_regexp
    Regexp.new(pattern, Regexp::IGNORECASE)
  end
end
