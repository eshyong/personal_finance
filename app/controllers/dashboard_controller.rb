class DashboardController < ApplicationController
  def index
    if performed?
      flash.keep
    end

    unless user_signed_in?
      redirect_to home_welcome_path
    end
  end
end
