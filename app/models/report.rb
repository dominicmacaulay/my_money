# frozen_string_literal: true

class Report
  MonthTotal = Data.define(:month, :income, :expense) do
    def profit
      income - expense
    end

    def name
      Date::ABBR_MONTHNAMES[month]
    end
  end

  class CategoryExpenseBreakdown
    attr_reader :category, :company, :year

    delegate :name, to: :category

    def initialize(category, company, year)
      @category = category
      @company = company
      @year = year
    end

    def total
      return category_total(category) if subcategories.none?

      details.sum { |detail| detail[:amount] }
    end

    def details
      @details ||= determine_details
    end

    private

    def determine_details
      return [] if subcategories.none?

      [category, *subcategories].map do |cat|
        { name: cat.name, amount: category_total(cat) }
      end
    end

    def subcategories
      @subcategories ||= category.subcategories.where(company:)
    end

    def category_total(category)
      Money.new(category.transactions.where(company:, date: year_range).sum(:amount_cents))
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
    Category.all.map { |category| CategoryExpenseBreakdown.new(category, company, year) }
  end

  def total_balance
    total_income - total_expense
  end

  def any_transactions?
    !(total_income.zero? && total_expense.zero?)
  end

  def monthly_breakdown
    @monthly_breakdown ||= (1..12).map do |month|
      MonthTotal.new(month:, income: month_total('income', month), expense: month_total('expense', month))
    end
  end

  def highest_income_month
    monthly_breakdown.reject { |month| month.income.zero? }.max_by(&:income)
  end

  def highest_expense_month
    monthly_breakdown.reject { |month| month.expense.zero? }.max_by(&:expense)
  end

  def highest_profit_month
    monthly_breakdown.reject { |month| month.income.zero? && month.expense.zero? }.max_by(&:profit)
  end

  private

  def monthly_totals
    @monthly_totals ||= company.transactions
                               .where(date: Date.new(year).all_year)
                               .group(:transaction_type, Arel.sql('EXTRACT(MONTH FROM date)::int'))
                               .sum(:amount_cents)
  end

  def month_total(type, month)
    Money.new(monthly_totals.fetch([type, month], 0))
  end
end
