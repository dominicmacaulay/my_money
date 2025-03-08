# frozen_string_literal: true

class TransactionsPresenter
  attr_reader :company, :grouping

  def initialize(company, grouping)
    @company = company
    @grouping = grouping
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

  private

  def authorized_transactions
    @authorized_transactions ||= company.transactions
  end
end
