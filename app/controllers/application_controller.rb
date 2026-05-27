class ApplicationController < ActionController::Base
  layout :layout_by_resource

  private

  def layout_by_resource
    if devise_controller? || (controller_name == "pages" && action_name == "home")
      "auth"
    else
      "application"
    end
  end
end
