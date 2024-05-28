class FinancialAccountsController < ApplicationController
  def index
  end

  def show
    return render_not_found unless user_signed_in?

    @account = current_user.financial_accounts.find(params[:id])
  end
end
