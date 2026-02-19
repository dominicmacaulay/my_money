# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages' do
  let(:user) { create(:user) }
  let!(:company) { create(:company) }

  before do
    login_as user
    visit root_path
  end

  describe 'Shared header' do
    context 'when user has a current company' do
      before do
        company.users << user
        user.switch_current_company(company)
      end

      it 'displays the company name' do
        page.refresh

        expect(page).to have_content(company.name)
      end
    end

    context 'when user does not have a current company' do
      it 'displays a link to set the current company' do
        expect(page).to have_link('Create Your Company')
        expect(page).to have_no_content(company.name)
      end
    end
  end

  describe 'Home page' do
    context 'when user has a current company' do
      let(:current_year) { Date.current.year }

      before do
        company.users << user
        user.switch_current_company(company)

        create_list(:transaction, 10, :income, company:, amount: 100, date: Date.new(current_year, 1, 1))
        create_list(:transaction, 5, :expense, company:, amount: 50, date: Date.new(current_year, 1, 1))
      end

      describe 'Yearly summary' do
        before do
          visit root_path
        end

        it 'displays the current year' do
          expect(page).to have_content(current_year)
        end

        it 'displays the total income for the current year' do
          total_income = company.income_for_year(current_year).format

          expect(page).to have_content("Total Income\n#{total_income}")
        end

        it 'displays the total expenses for the current year' do
          total_expenses = company.expense_for_year(current_year).format

          expect(page).to have_content("Total Expense\n#{total_expenses}")
        end

        it 'displays the total balance for the current year' do
          total_income = company.income_for_year(current_year)
          total_expenses = company.expense_for_year(current_year)
          total_balance = (total_income - total_expenses).format

          expect(page).to have_content("Total Balance\n#{total_balance}")
        end
      end
    end

    context 'when user does not have a current company' do
      it 'displays a welcome message' do
        expect(page).to have_content('Welcome to My Money!')
      end
    end
  end
end
