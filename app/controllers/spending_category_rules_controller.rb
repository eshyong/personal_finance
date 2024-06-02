class SpendingCategoryRulesController < ApplicationController
  def index
    @rules = current_user.spending_category_rules
  end

  def create
    redirect_to "home/welcome" unless user_signed_in?

    @rule = SpendingCategoryRule.new(rule_params)
    @rule.user = current_user

    begin
      if @rule.save
        if params[:apply_to_existing_transactions]
          SpendingCategoryRulesService.apply_rule_to_existing_transactions!(@rule, @rule.user)
        end
        flash.notice = "Spending category rule successfully created."
        redirect_back_or_to root_path
      else
        flash.alert = "Unable to save spending category rule."
        redirect_back_or_to root_path
      end
    rescue ActiveRecord::RecordNotUnique
      flash.alert = "A rule already exists with that pattern."
      redirect_back_or_to root_path
    end
  end

  def show
  end

  def destroy
  end

  private

  def rule_params
    params.require(:spending_category_rule).permit(:spending_category, :pattern, :apply_now)
  end
end
