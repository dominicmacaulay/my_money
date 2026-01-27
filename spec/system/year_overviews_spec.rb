# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Year Overviews' do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:last_year) { 1.year.ago.year }
  let(:this_year) { Time.current.year }

  let!(:last_year_incomes) { create_list(:transaction, 2, :income, company:, date: Date.new(last_year), amount: 100) }
  let!(:last_year_expenses) { create_list(:transaction, 2, :expense, company:, date: Date.new(last_year), amount: 50) }
  let!(:this_year_incomes) { create_list(:transaction, 5, :income, company:, date: Date.new(this_year), amount: 150) }
  let!(:this_year_expenses) { create_list(:transaction, 5, :expense, company:, date: Date.new(this_year), amount: 100) }

  before do
    user.companies << company
    user.switch_current_company(company)

    login_as user
    visit root_path
  end

  it 'can be listed' do
    click_on 'account_circle'
    click_on 'Year Overviews'

    expect(page).to have_content('View your financial data by year')

    find(data_test(last_year)).click
    within data_test(last_year) do
      income = last_year_incomes.sum(&:amount_cents) / 100
      expenses = last_year_expenses.sum(&:amount_cents) / 100
      expect(page).to have_content "Total Income\n$#{income}"
      expect(page).to have_content "Total Expense\n$#{expenses}"
      expect(page).to have_content "Total Balance\n$#{income - expenses}"
    end

    find(data_test(this_year)).click
    within data_test(this_year) do
      income = this_year_incomes.sum(&:amount_cents) / 100
      expenses = this_year_expenses.sum(&:amount_cents) / 100
      expect(page).to have_content "Total Income\n$#{income}"
      expect(page).to have_content "Total Expense\n$#{expenses}"
      expect(page).to have_content "Total Balance\n$#{income - expenses}"
    end
  end
end
