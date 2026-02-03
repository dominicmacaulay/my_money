# frozen_string_literal: true

class Report
  attr_reader :company, :year

  def initialize(company, year)
    @company = company
    @year = year
  end

  def total_income
    @total_income ||= company.income_for_year(year)
  end

  def total_expense
    @total_expense ||= company.expense_for_year(year)
  end

  def expense_breakdown
    Category.all.index_with do |category|
      { category_total: 
    end
  end

  def total_balance
    total_income - total_expense
  end

  private

  def expense_transactions
    @expense_transactions ||= company.transactions.expense.where(date: Date.new(year).all_year)
  end
end
