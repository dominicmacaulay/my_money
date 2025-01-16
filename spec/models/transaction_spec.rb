# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction do
  describe 'validations' do
    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:transaction_type) }

    it 'validates that the type is either income or expense' do
      transaction = described_class.new(transaction_type: "m'thinks")
      expect(transaction).not_to be_valid
      expect(transaction.errors[:transaction_type]).to include('is not included in the list')
    end

    it 'validates the numericality of amount' do
      transaction = described_class.new(amount: 'abc')
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include('is not a number')
    end

    it 'is valid with an amount having at most two decimal places' do
      transaction = described_class.new(amount: 123.45)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to be_empty
    end

    it 'is invalid with an amount having more than two decimal places' do
      transaction = described_class.new(amount: 123.456)
      expect(transaction).not_to be_valid
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

        expect(described_class.income).to eq([income_transaction])
      end
    end

    describe '.expenses' do
      it 'returns only expense transactions' do
        expense_transaction = create(:transaction, :expense)
        create(:transaction, :income)

        expect(described_class.expense).to eq([expense_transaction])
      end
    end
  end
end
