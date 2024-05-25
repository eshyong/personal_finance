class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.stripe_customer_id = Stripe::Customer.create(email: @user.email).id

    if @user.save
      @user.send_confirmation_email!
      redirect_to root_path, notice: "A confirmation email has been sent to your registered email."
    else
      flash.now[:alert] = "Unable to sign up user"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
