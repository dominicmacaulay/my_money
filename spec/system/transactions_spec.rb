# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transactions' do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let!(:category) { create(:category) }

  before do
    company.users << user
    user.switch_current_company(company)

    login_as user

    visit root_path
  end

  context 'when being listed' do
    let!(:expense_transaction) { create(:transaction, :expense, company:, amount: '100.00') }
    let!(:expense_transaction2) { create(:transaction, :expense, company:, amount: '150.00') }
    let!(:income_transaction) { create(:transaction, company:, amount: '200.00') }
    let!(:income_transaction2) { create(:transaction, company:, amount: '250.00') }
    let!(:last_year_expense_transaction) { create(:transaction, :expense, company:, amount: '40.00', date: 1.year.ago) }
    let!(:last_year_income_transaction) { create(:transaction, company:, amount: '300.00', date: 1.year.ago) }

    before do
      click_on 'account_circle'
      click_on 'Transactions'
    end

    context 'when on the Income tab' do
      before do
        click_on 'Income'
      end

      it 'only lists income transactions' do
        expect(page).to have_content('Transactions')

        within('tbody') do
          expect_transactions_to_be_listed([income_transaction, income_transaction2], show_type: false)
          expect_transactions_not_to_be_listed(
            [expense_transaction, expense_transaction2, last_year_expense_transaction, last_year_income_transaction]
          )
        end
      end

      context 'when changing the year' do
        before do
          click_on 'arrow_drop_down'
          click_on 1.year.ago.year.to_s
        end

        it 'lists only income transactions from that year' do
          expect(page).to have_content('Transactions')

          within('tbody') do
            expect_transactions_to_be_listed([last_year_income_transaction], show_type: false)
            expect_transactions_not_to_be_listed(
              [
                income_transaction,
                income_transaction2,
                expense_transaction,
                expense_transaction2,
                last_year_expense_transaction
              ]
            )
          end
        end
      end
    end

    context 'when on the All tab' do
      before do
        click_on 'All'
      end

      it 'lists all transactions' do
        expect(page).to have_content('Transactions')

        within('tbody') do
          expect_transactions_to_be_listed(
            [income_transaction, income_transaction2, expense_transaction, expense_transaction2]
          )
          expect_transactions_not_to_be_listed([last_year_expense_transaction, last_year_income_transaction])
        end
      end

      context 'when changing the year' do
        before do
          click_on 'arrow_drop_down'
          click_on 1.year.ago.year.to_s
        end

        it 'lists all transactions from that year' do
          expect(page).to have_content('Transactions')

          within('tbody') do
            expect_transactions_to_be_listed(
              [last_year_income_transaction, last_year_expense_transaction]
            )
            expect_transactions_not_to_be_listed(
              [
                income_transaction,
                income_transaction2,
                expense_transaction,
                expense_transaction2
              ]
            )
          end
        end
      end
    end

    context 'when on the Expense tab' do
      before do
        click_on 'Expense'
      end

      it 'only lists expense transactions' do
        expect(page).to have_content('Transactions')

        within('tbody') do
          expect_transactions_to_be_listed([expense_transaction, expense_transaction2], show_type: false)
          expect_transactions_not_to_be_listed(
            [income_transaction, income_transaction2, last_year_expense_transaction, last_year_income_transaction]
          )
        end
      end

      context 'when changing the year' do
        before do
          click_on 'arrow_drop_down'
          click_on 1.year.ago.year.to_s
        end

        it 'lists only expense transactions from that year' do
          expect(page).to have_content('Transactions')

          within('tbody') do
            expect_transactions_to_be_listed([last_year_expense_transaction], show_type: false)
            expect_transactions_not_to_be_listed(
              [
                income_transaction,
                income_transaction2,
                expense_transaction,
                expense_transaction2,
                last_year_income_transaction
              ]
            )
          end
        end
      end
    end

    it 'displays the total income' do
      expect(page).to have_content('Total Income')
      expect(page).to have_content((income_transaction.amount + income_transaction2.amount).format)
    end

    it 'displays the total expenses' do
      expect(page).to have_content('Total Expense')
      expect(page).to have_content((expense_transaction.amount + expense_transaction2.amount).format)
    end

    it 'displays the total balance' do
      total_income = income_transaction.amount + income_transaction2.amount
      total_expense = expense_transaction.amount + expense_transaction2.amount
      expect(page).to have_content('Total Balance')
      expect(page).to have_content((total_income - total_expense).format)
    end
  end

  context 'when being created' do
    let!(:subcategory) { create(:subcategory, category:, company:) }

    before do
      click_on 'account_circle'
      click_on 'Transactions'
    end

    it 'can be created as an income without a category', :js do
      click_on 'New Transaction'

      fill_in 'Date', with: Date.current
      fill_in 'Description', with: 'My New Transaction'
      select 'Income', from: 'Transaction type'
      fill_in 'Amount', with: '10000'
      click_on 'Create Transaction'

      expect(page).to have_content('Transaction was successfully created')
      expect(page).to have_content('My New Transaction')

      transaction = Transaction.all.max_by(&:id)
      expect(transaction).to be_income
      expect(transaction.amount).to eq Money.new(10_000, 'USD') # 100.00 USD
      expect(transaction.categorizable).to be_nil
      expect(transaction.date).to eq Date.current
      expect(transaction.description).to eq 'My New Transaction'
    end

    it 'can be created as an expense with a standard category', :js do
      click_on 'New Transaction'

      fill_in 'Date', with: Date.current
      fill_in 'Description', with: 'My New Transaction'
      select 'Expense', from: 'Transaction type'
      fill_in 'Amount', with: '10000'
      select category.name, from: 'Category'
      click_on 'Create Transaction'

      expect(page).to have_content('Transaction was successfully created')
      expect(page).to have_content('My New Transaction')

      transaction = Transaction.all.max_by(&:id)
      expect(transaction).to be_expense
      expect(transaction.amount).to eq Money.new(10_000, 'USD') # 100.00 USD
      expect(transaction.categorizable).to eq category
      expect(transaction.date).to eq Date.current
      expect(transaction.description).to eq 'My New Transaction'
    end

    it 'can be created as an expense with a subcategory', :js do
      click_on 'New Transaction'

      subcategory_name = "#{subcategory.name} (Subcategory of #{category.name})"
      fill_in 'Date', with: Date.current
      fill_in 'Description', with: 'My New Transaction'
      select 'Expense', from: 'Transaction type'
      fill_in 'Amount', with: '10000'
      select subcategory_name, from: 'Category'
      click_on 'Create Transaction'

      expect(page).to have_content('Transaction was successfully created')
      expect(page).to have_content('My New Transaction')

      transaction = Transaction.all.max_by(&:id)
      expect(transaction).to be_expense
      expect(transaction.amount).to eq Money.new(10_000, 'USD') # 100.00 USD
      expect(transaction.categorizable).to eq subcategory
      expect(transaction.date).to eq Date.current
      expect(transaction.description).to eq 'My New Transaction'
    end

    it 'does not show a delete button' do
      click_on 'New Transaction'

      expect(page).to have_content('Create Transaction')
      expect(page).to have_no_content('Delete')
    end

    context 'when navigating from the Income index page' do
      it 'prefills income as the transaction type' do
        click_on 'Income'
        click_on 'New Transaction'
        expect(page).to have_select('Transaction type', selected: 'Income')
      end
    end

    context 'when navigating from the All index page' do
      it 'prefills income as the transaction type' do
        click_on 'All'
        click_on 'New Transaction'
        expect(page).to have_select('Transaction type', selected: 'Income')
      end
    end

    context 'when navigating from the Expense index page' do
      it 'prefills expense as the transaction type' do
        click_on 'Expense'
        click_on 'New Transaction'
        expect(page).to have_select('Transaction type', selected: 'Expense')
      end
    end
  end

  context 'when being viewed', :js do
    let!(:transaction) { create(:transaction, company:) }

    before do
      click_on 'account_circle'
      click_on 'Transactions'

      click_on 'View'
    end

    it 'can be edited' do
      fill_in 'Description', with: 'My Updated Transaction'
      find_field('Amount').send_keys(%i[command backspace]) # Clear the value in place
      fill_in 'Amount', with: '50.00'
      click_on 'Update Transaction'

      expect(page).to have_content('Transaction was successfully updated')
      expect(page).to have_content('My Updated Transaction')

      transaction.reload
      expect(transaction.amount).to eq Money.new(5000, 'USD') # 50.00 USD
      expect(transaction.description).to eq 'My Updated Transaction'
    end

    it 'can be deleted' do
      expect do
        click_on 'Delete'
        click_on "Yes, I'm Sure"
        expect(page).to have_content('Transaction was successfully destroyed')
      end.to change(Transaction, :count).by(-1)
    end
  end

  def expect_transactions_to_be_listed(transactions, show_type: true) # rubocop:disable Metrics/AbcSize
    transactions.each do |transaction|
      expect(page).to have_content transaction.date
      expect(page).to have_content transaction.description
      expect(page).to have_content transaction.transaction_type.titleize if show_type
      expect(page).to have_content transaction.categorizable.name if transaction.expense?
      expect(page).to have_content transaction.amount.format
    end
  end

  def expect_transactions_not_to_be_listed(transactions)
    transactions.each do |transaction|
      expect(page).to have_no_content transaction.description
      expect(page).to have_no_content transaction.amount.format
    end
  end
end
