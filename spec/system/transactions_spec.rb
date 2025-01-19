# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transactions' do
  let(:user) { create(:user, current_company: company) }
  let(:company) { create(:company) }
  let!(:category) { create(:category) }

  before do
    login_as user

    visit root_path
  end

  context 'when being listed' do
    let!(:expense_transaction) { create(:transaction, :expense, company:, amount: '100.00') }
    let!(:expense_transaction2) { create(:transaction, :expense, company:, amount: '150.00') }
    let!(:income_transaction) { create(:transaction, company:, amount: '200.00') }
    let!(:income_transaction2) { create(:transaction, company:, amount: '250.00') }

    before do
      click_on 'Transactions'
    end

    it 'can be viewed' do
      expect(page).to have_content('Transactions')

      expect(page).to have_content expense_transaction.date
      expect(page).to have_content expense_transaction.description
      expect(page).to have_content expense_transaction.transaction_type.titleize
      expect(page).to have_content expense_transaction.categorizable&.name
      expect(page).to have_content expense_transaction.amount.format
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
    before do
      click_on 'Transactions'
      click_on 'New Transaction'
    end

    it 'can be created as an income without a category' do
      fill_in 'Date', with: '2021-01-01'
      fill_in 'Description', with: 'My New Transaction'
      select 'Income', from: 'Transaction type'
      fill_in 'Amount', with: '100'
      click_on 'Create Transaction'

      expect(page).to have_content('Transaction was successfully created')
      expect(page).to have_content('My New Transaction')
    end

    it 'can be created as an expense with a category' do
      fill_in 'Date', with: '2021-01-01'
      fill_in 'Description', with: 'My New Transaction'
      select 'Expense', from: 'Transaction type'
      fill_in 'Amount', with: '100'
      select category.name, from: 'Category'
      click_on 'Create Transaction'

      expect(page).to have_content('Transaction was successfully created')
      expect(page).to have_content('My New Transaction')
    end

    it 'does not show a delete button' do
      expect(page).to have_content('Create Transaction')
      expect(page).to have_no_content('Delete')
    end
  end

  context 'when being viewed', :js do
    let!(:transaction) { create(:transaction, company:) }

    before do
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
      expect(transaction.reload.amount).to eq Money.new(5000, 'USD') # 50.00 USD
    end

    it 'can be deleted' do
      expect do
        click_on 'Delete'
        expect(page).to have_content('Transaction was successfully destroyed')
      end.to change(Transaction, :count).by(-1)
    end
  end
end
