class DashboardController < ApplicationController
  def index
    flash.keep

    unless user_signed_in?
      redirect_to home_welcome_path
    end
  end
end
