# frozen_string_literal: true

class Report
  PeriodTotal = Data.define(:name, :income, :expense) do
    def profit
      income - expense
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
      PeriodTotal.new(name: Date::ABBR_MONTHNAMES[month],
                      income: month_total('income', month),
                      expense: month_total('expense', month))
    end
  end

  def weekly_breakdown
    @weekly_breakdown ||= week_starts.map do |starts_on|
      PeriodTotal.new(name: starts_on.strftime('%b %-d'),
                      income: week_total('income', starts_on),
                      expense: week_total('expense', starts_on))
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

  # Buckets run Monday to Sunday, so the first and last of the year reach a few days
  # outside it. Every transaction dated within the year still lands in exactly one.
  def week_starts
    (Date.new(year, 1, 1).beginning_of_week..Date.new(year, 12, 31).beginning_of_week).step(7)
  end

  def totals_grouped_by(expression)
    company.transactions
           .where(date: Date.new(year).all_year)
           .group(:transaction_type, Arel.sql(expression))
           .sum(:amount_cents)
  end

  # Without ::int the month keys come back as BigDecimal and every fetch below misses.
  def monthly_totals
    @monthly_totals ||= totals_grouped_by('EXTRACT(MONTH FROM date)::int')
  end

  def weekly_totals
    @weekly_totals ||= totals_grouped_by("DATE_TRUNC('week', date)::date")
                       .transform_keys { |type, week| [type, week.to_date] }
  end

  def month_total(type, month)
    Money.new(monthly_totals.fetch([type, month], 0))
  end

  def week_total(type, starts_on)
    Money.new(weekly_totals.fetch([type, starts_on], 0))
  end
end
