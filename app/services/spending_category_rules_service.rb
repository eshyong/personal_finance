class SpendingCategoryRulesService
  class << self
    def apply_rule_to_existing_transactions!(rule, user)
      # TODO: avoid quadratic time complexity...
      rules = user.spending_category_rules
      user.financial_accounts.each do |fa|
        fa.transactions.each do |t|
          rules.each do |r|
            if r.applies_to_transaction?(t)
              t.update!(spending_category: r.spending_category)
            end
          end
        end
      end
    end
  end
end
