# frozen_string_literal: true

class TransactionPolicy < ApplicationPolicy
  def index?
    user_has_company?
  end

  def new?
    user_has_company?
  end

  def edit?
    allow_action?
  end

  def create?
    allow_action?
  end

  def update?
    allow_action?
  end

  def destroy?
    allow_action? && user_admin?
  end
end
