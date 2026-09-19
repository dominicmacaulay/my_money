# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Reports' do
  let(:company) { create(:company) }
  let(:user) { create(:user, companies: [company]) }
  let(:this_year) { Time.current.year }

  let(:category) { create(:category) }
  let(:category2) { create(:category) }
  let(:subcategory) { create(:subcategory, category:, company:) }

  let!(:income_transactions) { create_list(:transaction, 5, :income, company:) }
  let!(:category_expenses) { create_list(:transaction, 3, :expense, company:, categorizable: category) }
  let!(:category2_expenses) { create_list(:transaction, 4, :expense, company:, categorizable: category2) }
  let!(:subcategory_expenses) { create_list(:transaction, 2, :expense, company:, categorizable: subcategory) }

  let(:total_income) { income_transactions.sum(&:amount) }
  let(:category_expenses_total) { category_expenses.sum(&:amount) }
  let(:subcategory_expenses_total) { subcategory_expenses.sum(&:amount) }
  let(:total_category_expenses) { category_expenses_total + subcategory_expenses_total }
  let(:total_category2_expenses) { category2_expenses.sum(&:amount) }
  let(:total_expenses) { total_category_expenses + total_category2_expenses }

  before do
    login_as user
    visit year_overviews_path

    # Create some transactions for last year
    last_year = this_year - 1
    create(:transaction, :income, company:, date: Date.new(last_year, 6, 15))
    create(:transaction, :expense, company:, date: Date.new(last_year, 7, 20), categorizable: category)
  end

  it 'navigates to the report for that year' do
    within data_test(this_year) do
      click_on 'View Report'
    end

    expect(page).to have_text 'Income'
    expect(page).to have_text total_income.format

    expect(page).to have_text 'Expenses'
    expect(page).to have_text category.name
    expect(page).to have_text total_category_expenses.format
    expect(page).to have_text category_expenses_total.format
    expect(page).to have_text subcategory.name
    expect(page).to have_text subcategory_expenses_total.format

    expect(page).to have_text category2.name
    expect(page).to have_text total_category2_expenses.format
  end

  describe 'monthly breakdown' do
    let(:chart_year) { this_year - 5 }

    let(:canvas_pixels) do
      <<~JS
        (() => {
          const canvas = document.querySelector('.chart__plot canvas')
          const pixels = canvas.getContext('2d').getImageData(0, 0, canvas.width, canvas.height).data
          return pixels.some((channel) => channel !== 0)
        })()
      JS
    end

    # Chart.js animates the bars in, so the canvas is blank for a moment after it mounts.
    def canvas_painted?
      20.times do
        return true if page.evaluate_script(canvas_pixels)

        sleep 0.1
      end

      false
    end

    before do
      create(:transaction, :income, company:, date: Date.new(chart_year, 2, 10), amount: 500)
      create(:transaction, :income, company:, date: Date.new(chart_year, 7, 3), amount: 900)
      create(:transaction, :expense, company:, categorizable: category, date: Date.new(chart_year, 3, 5), amount: 800)

      visit reports_path(year: chart_year)
    end

    it 'tabulates every month and names the standout months' do
      expect(page).to have_css '[data-controller="chart"]'

      expect(page).to have_css 'tr', text: /Feb\s*\$500\.00\s*\$0\.00/
      expect(page).to have_css 'tr', text: /Mar\s*\$0\.00\s*\$800\.00/

      expect(page).to have_css '.report__header', text: /Highest Income\s+Jul · \$900\.00/
      expect(page).to have_css '.report__header', text: /Highest Expense\s+Mar · \$800\.00/
      expect(page).to have_css '.report__header', text: /Highest Profit\s+Jul · \$900\.00/
    end

    it 'paints the chart', :js do
      expect(page).to have_css '.chart__plot canvas[style*="display: block"]'

      expect(canvas_painted?).to be true
    end

    context 'when the year has no transactions' do
      it 'shows an empty state instead of the chart' do
        visit reports_path(year: this_year - 6)

        expect(page).to have_text 'No transactions for this year yet.'
        expect(page).to have_no_css '[data-controller="chart"]'
      end
    end
  end
end
