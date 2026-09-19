# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Year Overviews' do
  let(:company) { create(:company) }
  let(:user) { create(:user, companies: [company]) }
  let(:last_year) { 1.year.ago.year }
  let(:this_year) { Time.current.year }

  let!(:last_year_incomes) { create_list(:transaction, 2, :income, company:, date: Date.new(last_year), amount: 100) }
  let!(:last_year_expenses) { create_list(:transaction, 2, :expense, company:, date: Date.new(last_year), amount: 50) }
  let!(:this_year_incomes) { create_list(:transaction, 5, :income, company:, date: Date.new(this_year), amount: 150) }
  let!(:this_year_expenses) { create_list(:transaction, 5, :expense, company:, date: Date.new(this_year), amount: 100) }

  before do
    login_as user
    visit root_path
  end

  it 'defers each year until its accordion is opened' do
    click_on 'account_circle'
    click_on 'Year Overviews'

    # No JS here, so the lazy frames never load; nothing year-specific should be inline.
    expect(page).to have_css 'turbo-frame[loading="lazy"]', count: 2, visible: :all
    expect(page).to have_no_text 'Total Income'
    expect(page).to have_no_css '[data-controller="chart"]', visible: :all
  end

  it 'can be listed', :js do
    click_on 'account_circle'
    click_on 'Year Overviews'

    expect(page).to have_text('View your financial data by year')

    find(data_test(last_year)).click
    within data_test(last_year) do
      income = last_year_incomes.sum(&:amount).format
      expenses = last_year_expenses.sum(&:amount).format
      total = (last_year_incomes.sum(&:amount) - last_year_expenses.sum(&:amount)).format

      expect(page).to have_text "Total Income\n#{income}"
      expect(page).to have_text "Total Expense\n#{expenses}"
      expect(page).to have_text "Total Balance\n#{total}"
    end

    find(data_test(this_year)).click
    within data_test(this_year) do
      income = this_year_incomes.sum(&:amount).format
      expenses = this_year_expenses.sum(&:amount).format
      total = (this_year_incomes.sum(&:amount) - this_year_expenses.sum(&:amount)).format

      expect(page).to have_text "Total Income\n#{income}"
      expect(page).to have_text "Total Expense\n#{expenses}"
      expect(page).to have_text "Total Balance\n#{total}"
    end
  end

  it 'shows a monthly breakdown for each year', :js do
    click_on 'account_circle'
    click_on 'Year Overviews'

    within data_test(this_year) do
      expect(page).to have_no_text 'monthly summary coming soon'
      expect(page).to have_css '[data-controller="chart"]'
      expect(page).to have_css '.text-pair', text: /Highest Income\s+Jan · \$750\.00/
      expect(page).to have_css '.text-pair', text: /Highest Profit\s+Jan · \$250\.00/
    end
  end
end
