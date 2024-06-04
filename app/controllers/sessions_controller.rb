class SessionsController < ApplicationController
  def new
    redirect_to dashboard_index_path if user_signed_in?
  end

  def create
    @user = User.find_by(email: params[:user][:email].downcase)

    if @user && @user.authenticate(params[:user][:password])
      reset_session
      session[:current_user_id] = @user.id
      redirect_to dashboard_index_path, notice: "Successfully logged in."
    else
      flash.now.alert = "Incorrect email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to home_welcome_path, notice: "Logged out."
  end
end
