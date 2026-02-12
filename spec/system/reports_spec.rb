# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reports' do
  let(:user) { create(:user) }
  let(:company) { create(:company, users: [user]) }
  let(:this_year) { Time.current.year }

  let(:category) { create(:category, :has_subcategory) }
  let(:category2) { create(:category) }
  let(:subcategory) { category.subcategories.first }

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
    visit year_overviews_path(company)

    # Create some transactions for last year
    last_year = this_year - 1
    create(:transaction, :income, company:, date: Date.new(last_year, 6, 15))
    create(:transaction, :expense, company:, date: Date.new(last_year, 7, 20), categorizable: category)
  end

  it 'navigates to the report for that year' do
    within data_test(this_year) do
      click_on 'View Report'
    end

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
end
