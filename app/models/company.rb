# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :user_companies, dependent: :destroy
  has_many :users, through: :user_companies
  has_many :subcategories, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :name, presence: true

  before_destroy :handle_destruction, prepend: true

  def add_user_with_role(user, role = :guest)
    user_companies.create(user:, role:)
  end

  def income_for_year(year)
    transaction_amounts_for_year(year, :income)
  end

  def expense_for_year(year)
    transaction_amounts_for_year(year, :expense)
  end

  private

  def transaction_amounts_for_year(year, type)
    Money.new(transactions.where(transaction_type: type, date: Date.new(year).all_year).sum(:amount_cents))
  end

  def handle_destruction
    users.each do |user|
      user.handle_company_destruction(self)
    end
  end
end
