# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reports' do
  let(:user) { create(:user) }
  let(:company) { create(:company, users: [user]) }
  let(:this_year) { Time.current.year }
  let(:last_year) { this_year - 1 }

  let(:category) { create(:category, :has_subcategory) }
  let(:category2) { create(:category) }
  let(:subcategory) { category.subcategories.first }

  let!(:last_year_income) { create(:transaction, :income, company:, date: Date.new(last_year, 6, 15)) }
  let!(:last_year_expense) { create(:transaction, :expense, company:, date: Date.new(last_year, 7, 20)) }

  let!(:income_transactions) { create_list(:transaction, 5, :income, company:) }
  let!(:category_expenses) { create_list(:transaction, 3, :expense, company:, categorizable: category) }
  let!(:category2_expenses) { create_list(:transaction, 4, :expense, company:, categorizable: category2) }
  let!(:subcategory_expenses) { create_list(:transaction, 2, :expense, company:, categorizable: subcategory) }

  let(:total_income) { income_transactions.sum(&:amount) }
  let(:total_category_expenses) { category_expenses.sum(&:amount) + subcategory_expenses.sum(&:amount) }
  let(:total_category2_expenses) { category2_expenses.sum(&:amount) }
  let(:total_expenses) { total_category_expenses + total_category2_expenses }
  let(:total_balance) { total_income - total_expenses }

  before do
    user.update!(current_company: company)
    login_as user
    visit company_reports_path(company)
  end

  it 'lists the reports for each year' do
    expect(page).to have_content this_year
    within data_test(this_year) do
      expect(page).to have_content total_income.to_s
      expect(page).to have_content total_expenses.to_s
      expect(page).to have_content total_balance.to_s
    end

    expect(page).to have_content last_year
    within data_test(last_year) do
      total_income = last_year_income.amount
      total_expenses = last_year_expense.amount
      balance = total_income - total_expenses

      expect(page).to have_content total_income.to_s
      expect(page).to have_content total_expenses.to_s
      expect(page).to have_content balance.to_s
    end
  end

  it 'shows the income, expenses for each category, and the balance' do
    click_on this_year.to_s

    expect(page).to have_content 'Income'
    expect(page).to have_content total_income.to_s

    expect(page).to have_content 'Expenses'
    expect(page).to have_content category.name
    expect(page).to have_content total_category_expenses.to_s

    expect(page).to have_content category2.name
    expect(page).to have_content total_category2_expenses.to_s

    expect(page).to have_content 'Balance'
    expect(page).to have_content total_balance.to_s
  end

  context 'when accessing from the year overview page' do
    before { visit year_overviews_path }

    it 'navigates to the report for that year' do
      within data_test(this_year) do
        expect(page).to have_link 'View Report', href: company_reports_path(company, year: this_year)
      end
    end
  end
end
