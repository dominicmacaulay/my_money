# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Years', type: :system do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:last_year) { 1.year.ago.year }
  let(:this_year) { Time.current.year }

  let!(:last_year_incomes) { create_list(:transaction, 2, :income, company:, date: Date.new(last_year)) }
  let!(:last_year_expenses) { create_list(:transaction, 2, :expense, company:, date: Date.new(last_year)) }
  let!(:this_year_incomes) { create_list(:transaction, 5, :income, company:, date: Date.new(this_year)) }
  let!(:this_year_expenses) { create_list(:transaction, 5, :expense, company:, date: Date.new(this_year)) }

  before do
    login_as user

    visit root_path
  end

  it 'can be listed' do
    click_on 'account_circle'
    click_on 'Years'

    expect(page).to have_content('View your financial data by year')

    click_on last_year.to_s
    within data_test(last_year) do
      income = last_year_incomes.sum(&:amount)
      expenses = last_year_expenses.sum(&:amount)
      expect(page).to have_content "Total Income: $#{income}"
      expect(page).to have_content "Total Expenses: $#{expenses}"
      expect(page).to have_content "Total Balance: $#{income - expenses}"
    end

    click_on this_year.to_s
    within data_test(this_year) do
      income = this_year_incomes.sum(&:amount)
      expenses = this_year_expenses.sum(&:amount)
      expect(page).to have_content "Total Income: $#{income}"
      expect(page).to have_content "Total Expenses: $#{expenses}"
      expect(page).to have_content "Total Balance: $#{income - expenses}"
    end
  end
end
