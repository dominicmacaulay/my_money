# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      raise NoMethodError, "You must define #resolve in #{self.class}"
    end

    private

    attr_reader :user, :scope
  end

  private

  def allow_action?
    user_has_company? && record_in_company?
  end

  def user_has_company?
    user.companies.exists?
  end

  def record_in_company?
    user.companies.exists?(id: record.company_id)
  end

  def user_admin?
    user.admin_for_company?(record.company)
  end
end
