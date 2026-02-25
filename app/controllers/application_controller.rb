# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_company

  def current_company
    @current_company ||= current_user.companies.find_by(id: current_company_id) # rubocop:disable Rails/FindByOrAssignmentMemoization
  end

  protected

  def set_current_company_id(company_id = current_user.companies.first&.id)
    session[:current_company_id] = company_id
  end

  private

  def current_company_id
    unless session[:current_company_id].present? && current_user.companies.exists?(id: session[:current_company_id])
      set_current_company_id
    end

    session[:current_company_id]
  end

  def user_not_authorized
    redirect_to(request.referer || root_path, alert: 'You are not authorized to perform this action.')
  end
end
