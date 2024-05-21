class DashboardController < ApplicationController
  def index
    unless current_user.present?
      redirect_to :root
    end
  end
end
