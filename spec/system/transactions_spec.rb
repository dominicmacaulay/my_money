# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Transactions' do
  let(:user) { create(:user, current_company: company) }
  let(:company) { create(:company) }

  before do
    login_as user

    visit root_path
    click_on 'Transactions'
  end

  context 'when being created' do
    before do
      click_on 'New Transaction'
    end

    it 'can be created' do
      fill_in 'Description', with: 'My New Transaction'
      select 'Income', from: 'Transaction type'
      fill_in 'Amount', with: '100'
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
      select 'Expense', from: 'Transaction type'
      find_field('Amount').send_keys(%i[command backspace]) # Clear the value in place
      fill_in 'Amount', with: '50.00'
      click_on 'Update Transaction'

      expect(page).to have_content('Transaction was successfully updated')
      expect(transaction.reload.description).to eql 'My Updated Transaction'
      expect(transaction.transaction_type).to eql 'expense'
      expect(transaction.amount).to eq Money.new(5000, 'USD') # 50.00 USD
    end

    it 'can be deleted' do
      expect do
        click_on 'Delete'
        expect(page).to have_content('Transaction was successfully destroyed')
      end.to change(Transaction, :count).by(-1)
    end
  end
end
