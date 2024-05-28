class ApplicationController < ActionController::Base
  include Authenticated

  def render_not_found
    render file: "#{Rails.root}/public/404.html", status: :not_found
  end
end
