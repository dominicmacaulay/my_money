# frozen_string_literal: true

class Report
  CENTS_TO_DOLLARS = 100.0

  class CategoryExpenseBreakdown
    attr_reader :category, :company, :year

    def initialize(category, company, year)
      @category = category
      @company = company
      @year = year
    end

    def total
      return category_total(category) if subcategories.none?

      breakdown.sum { it[:amount] }
    end

    def breakdown
      return [] if subcategories.none?

      [category, *subcategories].map do |cat|
        { name: cat.name, amount: category_total(cat) }
      end
    end

    private

    def subcategories
      @subcategories ||= category.subcategories.where(company:)
    end

    def category_total(category)
      category.transactions.where(company:, date: year_range).sum(:amount_cents) / CENTS_TO_DOLLARS
    end

    def year_range
      @year_range ||= Date.new(year).all_year
    end
  end

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
    Category.all.map { CategoryExpenseBreakdown.new(it, company, year) }
  end

  def total_balance
    total_income - total_expense
  end
end
