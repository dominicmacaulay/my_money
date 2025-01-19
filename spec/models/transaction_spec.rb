# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction do
  it { should monetize(:amount_cents) }

  describe 'validations' do
    it { should validate_presence_of(:date) }
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

    it 'validates that the amount is greater than 0' do
      transaction = described_class.new(amount: 0)
      expect(transaction).not_to be_valid
      expect(transaction.errors[:amount]).to include('must be greater than 0')
    end
  end

  describe 'associations' do
    it { should belong_to(:company) }

    context 'when the transaction is an expense' do
      it 'belongs to a categorizable' do
        transaction = build(:transaction, :expense, categorizable: nil)

        expect(transaction).not_to be_valid
        expect(transaction.errors[:categorizable]).to include('must be present for expense transactions')
      end
    end

    context 'when the transaction is an income' do
      it 'does not belong to a categorizable' do
        transaction = create(:transaction, :income)

        expect(transaction).to be_valid
      end
    end
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
