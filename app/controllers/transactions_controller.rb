class TransactionsController < ApplicationController
  def index
    unless user_signed_in?
      render json: {"error": "you must be signed in to view account transactions"}, status: :forbidden
      return
    end

    @account = FinancialAccount.find(params[:financial_account_id])
    render json: @account.transactions
  end
end
