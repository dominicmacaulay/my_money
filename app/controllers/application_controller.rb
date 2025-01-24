# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_company

  private

  def current_company
    current_user&.current_company
  end

  def user_not_authorized
    redirect_to(request.referer || root_path, alert: 'You are not authorized to perform this action.')
  end
end
