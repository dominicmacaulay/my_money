# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsPresenter do
  let(:presenter) { described_class.new(company, grouping) }
  let(:company) { create(:company) }
  let(:grouping) { :all }

  before do
    create_list(:transaction, 2) # create transactions for other companies

    create_list(:transaction, 2, :expense, company:)
    create_list(:transaction, 2, :income, company:)
  end

  describe '#transactions' do
    context 'when grouping is all' do
      let(:grouping) { :all }

      it 'returns all the correct company\'s transactions ordered by date' do
        expected_transactions = company.transactions.order(date: :desc)
        received_transactions = presenter.transactions

        expect(received_transactions).to eq(expected_transactions)
      end
    end

    context 'when grouping is income' do
      let(:grouping) { :income }

      it 'returns all income the correct company\'s transactions ordered by date' do
        expected_transactions = company.transactions.income.order(date: :desc)
        received_transactions = presenter.transactions

        expect(received_transactions).to eq(expected_transactions)
      end
    end

    context 'when grouping is expense' do
      let(:grouping) { :expense }

      it 'returns all expense the correct company\'s transactions ordered by date' do
        expected_transactions = company.transactions.expense.order(date: :desc)
        received_transactions = presenter.transactions

        expect(received_transactions).to eq(expected_transactions)
      end
    end
  end

  describe '#total_income' do
    it 'returns the total income' do
      expected_total_income = company.transactions.income.sum(:amount_cents) / 100
      received_total_income = presenter.total_income

      expect(received_total_income).to eq(expected_total_income)
    end
  end

  describe '#total_expense' do
    it 'returns the total expense' do
      expected_total_expense = company.transactions.expense.sum(:amount_cents) / 100
      received_total_expense = presenter.total_expense

      expect(received_total_expense).to eq(expected_total_expense)
    end
  end

  describe '#balance' do
    it 'returns the balance' do
      expected_balance = presenter.total_income - presenter.total_expense
      received_balance = presenter.balance

      expect(received_balance).to eq(expected_balance)
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
end
