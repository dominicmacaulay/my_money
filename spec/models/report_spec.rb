# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report do
  let(:company) { create(:company) }
  let(:year) { DateTime.current.year }
  let(:report) { described_class.new(company, year) }

  let(:category1) { create(:category) }
  let(:category2) { create(:category) }
  let(:subcategory) { create(:subcategory, category: category1, company:) }

  let(:date) { Date.new(year, 1, 1) }
  let!(:income) do
    create_list(:transaction, 5, :income, company:, date:)
  end
  let!(:category1_expenses) do
    create_list(:transaction, 3, :expense, company:, categorizable: category1, date:)
  end
  let!(:category2_expenses) do
    create_list(:transaction, 2, :expense, company:, categorizable: category2, date:)
  end
  let!(:subcategory_expenses) do
    create_list(:transaction, 2, :expense, company:, categorizable: subcategory, date:)
  end

  before do
    # Create transactions for another company to ensure they are not counted
    irrelevant_company = create(:company)
    irrelevant_subcategory = create(:subcategory, category: category1, company: irrelevant_company)
    create_list(:transaction, 3, :income, company: irrelevant_company, date:)
    create_list(:transaction, 2, :expense, company: irrelevant_company, categorizable: category1, date:)
    create_list(:transaction, 2, :expense, company: irrelevant_company, categorizable: category2, date:)
    create_list(:transaction, 2, :expense, company: irrelevant_company, categorizable: irrelevant_subcategory, date:)

    # Create transactions for the same company but different year to ensure they are not counted
    create_list(:transaction, 3, :income, company:, date: date - 1.year)
    create_list(:transaction, 2, :expense, company:, categorizable: category1, date: date - 1.year)
    create_list(:transaction, 2, :expense, company:, categorizable: category2, date: date - 1.year)
    create_list(:transaction, 2, :expense, company:, categorizable: subcategory, date: date - 1.year)
  end

  describe 'totals' do
    let(:total_income) { income.sum(&:amount_cents) / 100 }
    let(:total_expense) do
      (category1_expenses.sum(&:amount_cents) +
      category2_expenses.sum(&:amount_cents) +
      subcategory_expenses.sum(&:amount_cents)) / 100
    end

    describe '#total_income' do
      it 'returns the total income for the year' do
        expect(report.total_income).to eq total_income
      end
    end

    describe '#total_expense' do
      it 'returns the total expense for the year' do
        expect(report.total_expense).to eq total_expense
      end
    end

    describe '#total_balance' do
      it 'returns the total balance for the year' do
        expect(report.total_balance).to eq total_income - total_expense
      end
    end
  end

  describe '#expense_breakdown' do
    let(:cat1_total) { category1_expenses.sum(&:amount_cents) / 100 }
    let(:cat2_total) { category2_expenses.sum(&:amount_cents) / 100 }
    let(:subcat_total) { subcategory_expenses.sum(&:amount_cents) / 100 }

    it 'returns an array of category expense breakdown objects with the broken down information' do
      breakdown = report.expense_breakdown

      expect(breakdown.size).to eq 2
      category1_breakdown = breakdown.find { it.category == category1 }
      category2_breakdown = breakdown.find { it.category == category2 }

      # Show a detailed breakdown for categories that have subcategories
      expect(category1_breakdown.total).to eq cat1_total + subcat_total
      expect(category1_breakdown.breakdown.size).to eq 2

      expect(category1_breakdown.breakdown.first[:name]).to eq category1.name
      expect(category1_breakdown.breakdown.first[:amount]).to eq cat1_total
      expect(category1_breakdown.breakdown.second[:name]).to eq subcategory.name
      expect(category1_breakdown.breakdown.second[:amount]).to eq subcat_total

      # Exclude the breakdown for categories that don't have subcategories
      expect(category2_breakdown.total).to eq cat2_total
      expect(category2_breakdown.breakdown).to be_empty
    end
  end

  describe 'edge cases' do
    context 'when there are no transactions for the year' do
      let(:empty_year) { year + 1 }
      let(:empty_report) { described_class.new(company, empty_year) }

      it 'returns zero for all totals' do
        expect(empty_report.total_income).to eq 0
        expect(empty_report.total_expense).to eq 0
        expect(empty_report.total_balance).to eq 0
      end
    end

    context 'when there are only income transactions' do
      let(:income_only_year) { year + 2 }
      let(:income_only_report) { described_class.new(company, income_only_year) }
      let!(:income_only_transactions) do
        create_list(:transaction, 3, :income, company:, date: Date.new(income_only_year, 1, 1))
      end

      it 'returns correct income, zero expense, and positive balance' do
        expected_income = income_only_transactions.sum(&:amount_cents) / 100

        expect(income_only_report.total_income).to eq expected_income
        expect(income_only_report.total_expense).to eq 0
        expect(income_only_report.total_balance).to eq expected_income
      end
    end

    context 'when there are only expense transactions' do
      let(:expense_only_year) { year + 3 }
      let(:expense_only_report) { described_class.new(company, expense_only_year) }
      let!(:expense_only_transactions) do
        create_list(:transaction, 3, :expense, company:, categorizable: category1,
                                               date: Date.new(expense_only_year, 1, 1))
      end

      it 'returns zero income, correct expense, and negative balance' do
        expected_expense = expense_only_transactions.sum(&:amount_cents) / 100

        expect(expense_only_report.total_income).to eq 0
        expect(expense_only_report.total_expense).to eq expected_expense
        expect(expense_only_report.total_balance).to eq(-expected_expense)
      end
    end
  end

  describe 'memoization' do
    it 'does not recalculate total_income on subsequent calls' do
      expect(company).to receive(:income_for_year).with(year).once.and_call_original

      report.total_income
      report.total_income
    end

    it 'does not recalculate total_expense on subsequent calls' do
      expect(company).to receive(:expense_for_year).with(year).once.and_call_original

      report.total_expense
      report.total_expense
    end
  end

  describe Report::CategoryExpenseBreakdown do
    let(:category_breakdown) { described_class.new(category1, company, year) }

    describe '#total' do
      context 'when category has no subcategories' do
        it 'returns the category total' do
          breakdown = described_class.new(category2, company, year)
          expect(breakdown.total).to eq category2_expenses.sum(&:amount_cents) / 100
        end
      end

      context 'when category has subcategories' do
        it 'returns the sum of category and all subcategories' do
          expected_total = (category1_expenses.sum(&:amount_cents) +
                           subcategory_expenses.sum(&:amount_cents)) / 100
          expect(category_breakdown.total).to eq expected_total
        end
      end

      context 'when category has no transactions' do
        let(:empty_category) { create(:category) }
        let(:empty_breakdown) { described_class.new(empty_category, company, year) }

        it 'returns zero' do
          expect(empty_breakdown.total).to eq 0
        end
      end

      context 'when category has only subcategory transactions' do
        let(:parent_category) { create(:category) }
        let(:child_subcategory) { create(:subcategory, category: parent_category, company:) }
        let!(:child_transactions) do
          create_list(:transaction, 3, :expense, company:, categorizable: child_subcategory, date:)
        end

        it 'returns the sum of only subcategories' do
          parent_breakdown = described_class.new(parent_category, company, year)
          expected_child_total = child_transactions.sum(&:amount_cents) / 100

          expect(parent_breakdown.total).to eq expected_child_total
        end
      end
    end

    describe '#breakdown' do
      context 'when category has no subcategories' do
        it 'returns an empty array' do
          breakdown = described_class.new(category2, company, year)
          expect(breakdown.breakdown).to be_empty
        end
      end

      context 'when category has subcategories' do
        it 'returns breakdown for parent and all subcategories' do
          expect(category_breakdown.breakdown.size).to eq 2
          expect(category_breakdown.breakdown.first[:name]).to eq category1.name
          expect(category_breakdown.breakdown.second[:name]).to eq subcategory.name
        end

        it 'includes correct amounts for each item' do
          parent_item = category_breakdown.breakdown.find { it[:name] == category1.name }
          sub_item = category_breakdown.breakdown.find { it[:name] == subcategory.name }

          expect(parent_item[:amount]).to eq category1_expenses.sum(&:amount_cents) / 100
          expect(sub_item[:amount]).to eq subcategory_expenses.sum(&:amount_cents) / 100
        end
      end

      context 'when category has multiple subcategories' do
        let(:subcategory2) { create(:subcategory, category: category1, company:) }

        before do
          create_list(:transaction, 2, :expense, company:, categorizable: subcategory2, date:)
        end

        it 'includes all subcategories in breakdown' do
          expect(category_breakdown.breakdown.size).to eq 3
          names = category_breakdown.breakdown.map { it[:name] }
          expect(names).to include(category1.name, subcategory.name, subcategory2.name)
        end
      end

      context 'when subcategory belongs to different company' do
        let(:other_company) { create(:company) }
        let(:other_subcategory) { create(:subcategory, category: category1, company: other_company) }

        before do
          create_list(:transaction, 3, :expense, company: other_company,
                                                 categorizable: other_subcategory, date:)
        end

        it 'excludes subcategories from other companies' do
          names = category_breakdown.breakdown.map { it[:name] }
          expect(names).not_to include(other_subcategory.name)
        end
      end

      context 'when category has only subcategory transactions' do
        let(:parent_category) { create(:category) }
        let(:child_subcategory) { create(:subcategory, category: parent_category, company:) }
        let!(:child_transactions) do
          create_list(:transaction, 3, :expense, company:, categorizable: child_subcategory, date:)
        end

        it 'shows zero for parent category and amounts for subcategories' do
          parent_breakdown = described_class.new(parent_category, company, year)
          expected_child_total = child_transactions.sum(&:amount_cents) / 100

          expect(parent_breakdown.breakdown.size).to eq 2

          parent_amount = parent_breakdown.breakdown.find { it[:name] == parent_category.name }
          child_amount = parent_breakdown.breakdown.find { it[:name] == child_subcategory.name }

          expect(parent_amount[:amount]).to eq 0
          expect(child_amount[:amount]).to eq expected_child_total
        end
      end
    end
  end
end
