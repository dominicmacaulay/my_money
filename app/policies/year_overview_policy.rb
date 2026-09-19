# frozen_string_literal: true

class YearOverviewPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end
end
