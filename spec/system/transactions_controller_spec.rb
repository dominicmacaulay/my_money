require 'rails_helper'

RSpec.describe 'Transactions', type: :system do
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
      expect(page).not_to have_content('Delete')
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
      fill_in 'Amount', with: '50'
      click_on 'Update Transaction'

      expect(page).to have_content('Transaction was successfully updated')
      expect(transaction.reload.description).to eql 'My Updated Transaction'
      expect(transaction.transaction_type).to eql 'Expense'
      expect(transaction.amount).to eql 50
    end

    it 'can be deleted' do
      expect {
        click_on 'Delete'
        expect(page).to have_content('Transaction was successfully destroyed')
      }.to change(Transaction, :count).by(-1)
    end
  end
end