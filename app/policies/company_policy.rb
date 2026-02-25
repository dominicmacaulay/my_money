# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  def index?
    true
  end

  def set_current?
    true
  end

  def show?
    true
  end

  def new?
    true
  end

  def edit?
    user_admin?
  end

  def create?
    true
  end

  def update?
    user_admin?
  end

  def destroy?
    user_admin?
  end

  private

  def user_admin?
    user.admin_for_company?(record)
  end
end
