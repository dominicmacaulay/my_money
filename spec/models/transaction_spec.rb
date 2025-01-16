# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:transaction_type) }

    it 'validates that the type is either income or expense' do
      transaction = Transaction.new(transaction_type: "m'thinks")
      expect(transaction).to be_invalid
      expect(transaction.errors[:transaction_type]).to include('is not included in the list')
    end

    it 'validates the numericality of amount' do
      transaction = Transaction.new(amount: 'abc')
      expect(transaction).to be_invalid
      expect(transaction.errors[:amount]).to include('is not a number')
    end

    it 'is valid with an amount having at most two decimal places' do
      transaction = Transaction.new(amount: 123.45)
      expect(transaction).to be_invalid
      expect(transaction.errors[:amount]).to be_empty
    end

    it 'is invalid with an amount having more than two decimal places' do
      transaction = Transaction.new(amount: 123.456)
      expect(transaction).to be_invalid
      expect(transaction.errors[:amount]).to include('must have at most two decimal places')
    end
  end

  describe 'associations' do
    it { should belong_to(:company) }
  end

  describe 'scopes' do
    describe '.incomes' do
      it 'returns only income transactions' do
        income_transaction = create(:transaction, :income)
        create(:transaction, :expense)

        expect(Transaction.income).to eq([income_transaction])
      end
    end

    describe '.expenses' do
      it 'returns only expense transactions' do
        expense_transaction = create(:transaction, :expense)
        create(:transaction, :income)

        expect(Transaction.expense).to eq([expense_transaction])
      end
    end
  end
end
