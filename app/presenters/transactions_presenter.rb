# frozen_string_literal: true

class TransactionsPresenter
  attr_reader :company, :grouping, :year

  def initialize(company, grouping, year)
    @company = company
    @grouping = grouping
    @year = Date.new(year || Time.current.year).all_year
  end

  def transactions
    authorized_transactions.send(grouping).order(date: :desc)
  end

  def total_income
    authorized_transactions.income.sum(:amount_cents) / 100
  end

  def total_expense
    authorized_transactions.expense.sum(:amount_cents) / 100
  end

  def balance
    total_income - total_expense
  end

  def transaction_type
    grouping == :expense ? :expense : :income
  end

  def show_category?
    grouping != :income
  end

  def show_transaction_type?
    grouping == :all
  end

  def pagination_colspan
    if show_category? && show_transaction_type?
      3
    elsif show_category? || show_transaction_type?
      2
    else
      1
    end
  end

  private

  def authorized_transactions
    @authorized_transactions ||= company.transactions.where(date: year)
  end
end
