# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsPresenter do
  let(:presenter) { described_class.new(company, grouping, year) }
  let(:company) { create(:company) }
  let(:grouping) { :all }
  let(:last_year) { 1.year.ago }
  let(:year) { nil }

  before do
    create_list(:transaction, 2) # create transactions for other companies
    # create transactions for the last year
    create_list(:transaction, 2, :expense, company:, date: last_year)
    create_list(:transaction, 2, :income, company:, date: last_year)

    create_list(:transaction, 2, :expense, company:)
    create_list(:transaction, 2, :income, company:)
  end

  describe '#transactions' do
    context 'when grouping is all' do
      let(:grouping) { :all }

      it 'returns all the correct company\'s transactions for the current year ordered by date' do
        expected_transactions = company.transactions.where(date: Date.current.all_year).order(date: :desc)
        received_transactions = presenter.transactions

        expect(received_transactions).to eq(expected_transactions)
      end
    end

    context 'when grouping is income' do
      let(:grouping) { :income }

      it 'returns all income the correct company\'s transactions for the current year ordered by date' do
        expected_transactions = company.transactions.income.where(date: Date.current.all_year).order(date: :desc)
        received_transactions = presenter.transactions

        expect(received_transactions).to eq(expected_transactions)
      end
    end

    context 'when grouping is expense' do
      let(:grouping) { :expense }

      it 'returns all expense the correct company\'s transactions for the current year ordered by date' do
        expected_transactions = company.transactions.expense.where(date: Date.current.all_year).order(date: :desc)
        received_transactions = presenter.transactions

        expect(received_transactions).to eq(expected_transactions)
      end
    end

    context 'when year is specified' do
      let(:year) { last_year.year }

      it 'returns all the correct company\'s transactions for the specified year ordered by date' do
        expected_transactions = company.transactions.where(date: last_year.all_year).order(date: :desc)
        received_transactions = presenter.transactions

        expect(received_transactions).to eq(expected_transactions)
      end
    end
  end

  describe '#total_income' do
    it 'returns the total income' do
      expected_total_income = company.transactions.income.where(date: Date.current.all_year).sum(:amount_cents) / 100
      received_total_income = presenter.total_income

      expect(received_total_income).to eq(expected_total_income)
    end

    context 'when a year is specified' do
      let(:year) { last_year.year }

      it 'returns the total income for the specified year' do
        expected_total_income = company.transactions.income.where(date: last_year.all_year).sum(:amount_cents) / 100
        received_total_income = presenter.total_income

        expect(received_total_income).to eq(expected_total_income)
      end
    end
  end

  describe '#total_expense' do
    it 'returns the total expense' do
      expected_total_expense = company.transactions.expense.where(date: Date.current.all_year).sum(:amount_cents) / 100
      received_total_expense = presenter.total_expense

      expect(received_total_expense).to eq(expected_total_expense)
    end

    context 'when a year is specified' do
      let(:year) { last_year.year }

      it 'returns the total expense for the specified year' do
        expected_total_expense = company.transactions.expense.where(date: last_year.all_year).sum(:amount_cents) / 100
        received_total_expense = presenter.total_expense

        expect(received_total_expense).to eq(expected_total_expense)
      end
    end
  end

  describe '#balance' do
    it 'returns the balance' do
      income = company.transactions.income.where(date: Date.current.all_year).sum(:amount_cents) / 100
      expense = company.transactions.expense.where(date: Date.current.all_year).sum(:amount_cents) / 100
      expected_balance = income - expense
      received_balance = presenter.balance

      expect(received_balance).to eq(expected_balance)
    end

    context 'when a year is specified' do
      let(:year) { last_year.year }

      it 'returns the balance for the specified year' do
        income = company.transactions.income.where(date: last_year.all_year).sum(:amount_cents) / 100
        expense = company.transactions.expense.where(date: last_year.all_year).sum(:amount_cents) / 100
        expected_balance = income - expense
        received_balance = presenter.balance

        expect(received_balance).to eq(expected_balance)
      end
    end
  end

  describe '#transaction_type' do
    context 'when grouping is expense' do
      let(:grouping) { :expense }

      it 'returns expense' do
        expect(presenter.transaction_type).to eq(:expense)
      end
    end

    context 'when grouping is income' do
      let(:grouping) { :income }

      it 'returns income' do
        expect(presenter.transaction_type).to eq(:income)
      end
    end

    context 'when grouping is all' do
      let(:grouping) { :all }

      it 'returns income as default' do
        expect(presenter.transaction_type).to eq(:income)
      end
    end
  end

  describe '#show_category?' do
    context 'when grouping is expense' do
      let(:grouping) { :expense }

      it 'returns true' do
        expect(presenter.show_category?).to be true
      end
    end

    context 'when grouping is income' do
      let(:grouping) { :income }

      it 'returns false' do
        expect(presenter.show_category?).to be false
      end
    end

    context 'when grouping is all' do
      let(:grouping) { :all }

      it 'returns true' do
        expect(presenter.show_category?).to be true
      end
    end
  end

  describe '#show_transaction_type?' do
    context 'when grouping is expense' do
      let(:grouping) { :expense }

      it 'returns false' do
        expect(presenter.show_transaction_type?).to be false
      end
    end

    context 'when grouping is income' do
      let(:grouping) { :income }

      it 'returns false' do
        expect(presenter.show_transaction_type?).to be false
      end
    end

    context 'when grouping is all' do
      let(:grouping) { :all }

      it 'returns true' do
        expect(presenter.show_transaction_type?).to be true
      end
    end
  end

  describe '#pagination_colspan' do
    context 'when grouping is expense' do
      let(:grouping) { :expense }

      it 'returns 2' do
        expect(presenter.pagination_colspan).to eq(2)
      end
    end

    context 'when grouping is income' do
      let(:grouping) { :income }

      it 'returns 1' do
        expect(presenter.pagination_colspan).to eq(1)
      end
    end

    context 'when grouping is all' do
      let(:grouping) { :all }

      it 'returns 3' do
        expect(presenter.pagination_colspan).to eq(3)
      end
    end
  end
end
