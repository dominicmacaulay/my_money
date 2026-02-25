# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company do
  let(:company) { create(:company) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe '#add_user_with_role' do
    it 'adds a user with a role' do
      user = create(:user)
      company.add_user_with_role(user, 'admin')
      expect(company.users).to include(user)

      user_company = company.user_companies.first
      expect(user_company.role).to eq('admin')
    end
  end

  describe 'transaction methods' do
    let(:income_transactions) { create_list(:transaction, 3, :income, company:, date: DateTime.current) }
    let(:expense_transactions) { create_list(:transaction, 2, :expense, company:, date: DateTime.current) }

    before do
      # Create transactions for last year to ensure they are not counted
      create(:transaction, :income, company:, date: 1.year.ago)
      create(:transaction, :expense, company:, date: 1.year.ago)
    end

    describe '#income_for_year' do
      it 'calculates total income for the given year' do
        total_income = income_transactions.sum(&:amount)
        expect(company.income_for_year(Date.current.year)).to eq(total_income)
      end

      it 'returns 0 if no transactions are found for the year' do
        expect(company.income_for_year(1900)).to eq(0)
      end
    end

    describe '#expense_for_year' do
      it 'calculates total expense for the given year' do
        total_expense = expense_transactions.sum(&:amount)
        expect(company.expense_for_year(Date.current.year)).to eq(total_expense)
      end

      it 'returns 0 if no transactions are found for the year' do
        expect(company.expense_for_year(1900)).to eq(0)
      end
    end
  end
end
