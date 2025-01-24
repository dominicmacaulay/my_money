# frozen_string_literal: true

class TransactionPolicy < ApplicationPolicy
  def index?
    current_company_exists?
  end

  def new?
    current_company_exists?
  end

  def edit?
    allow_action?
  end

  def create?
    current_company_exists?
  end

  def update?
    allow_action?
  end

  def destroy?
    allow_action? && user_admin?
  end

  private

  def allow_action?
    current_company_exists? && record_in_company?
  end

  def current_company_exists?
    user.current_company.present?
  end

  def record_in_company?
    record.company == user.current_company
  end

  def user_admin?
    user.user_companies.find_by(company: user.current_company).admin?
  end
end
