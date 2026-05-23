class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  layout :layout_by_resource

  private

  # Auth + onboarding use the clean full-screen layout; the rest use the
  # mobile app shell (with the bottom tab bar).
  def layout_by_resource
    if devise_controller? || (controller_name == "pages" && action_name == "home")
      "auth"
    else
      "application"
    end
  end
end
