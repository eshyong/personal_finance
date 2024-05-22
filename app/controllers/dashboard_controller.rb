class DashboardController < ApplicationController
  def index
    unless current_user.present?
      redirect_to home_welcome_path
    end
  end
end
