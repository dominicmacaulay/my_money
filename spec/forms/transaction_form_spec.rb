# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionForm do
  let(:company) { create(:company) }
  let(:attributes) do
    { date: '2026-01-31', amount: '25.00', transaction_type: 'income', company_id: company.id, description: 'Rent' }
  end

  describe '#save' do
    context 'when not recurring' do
      it 'creates a single transaction' do
        form = described_class.new(attributes)

        expect { form.save }.to change(Transaction, :count).by(1)
        expect(form.transaction).to be_persisted
      end
    end

    context 'when recurring' do
      it 'creates a transaction for each occurrence through the end date' do
        form = described_class.new(attributes.merge(recurring: '1', frequency: 'weekly', end_date: '2026-02-21'))

        expect { form.save }.to change(Transaction, :count).by(4)
        expect(company.transactions.order(:date).pluck(:date)).to eq(
          [Date.new(2026, 1, 31), Date.new(2026, 2, 7), Date.new(2026, 2, 14), Date.new(2026, 2, 21)]
        )
        expect(company.transactions.pluck(:description).uniq).to eq(['Rent'])
      end

      it 'keeps monthly occurrences anchored to the start day' do
        form = described_class.new(attributes.merge(recurring: '1', frequency: 'monthly', end_date: '2026-04-30'))

        form.save

        expect(company.transactions.order(:date).pluck(:date)).to eq(
          [Date.new(2026, 1, 31), Date.new(2026, 2, 28), Date.new(2026, 3, 31), Date.new(2026, 4, 30)]
        )
      end

      it 'requires a frequency and end date' do
        form = described_class.new(attributes.merge(recurring: '1'))

        expect(form.save).to be(false)
        expect(form.errors[:frequency]).to include('is not included in the list')
        expect(form.errors[:end_date]).to include("can't be blank")
      end

      it 'requires the end date to be after the transaction date' do
        form = described_class.new(attributes.merge(recurring: '1', frequency: 'daily', end_date: '2026-01-31'))

        expect(form.save).to be(false)
        expect(form.errors[:end_date]).to include('must be after the transaction date')
      end

      it 'limits how many transactions can be created at once' do
        form = described_class.new(attributes.merge(recurring: '1', frequency: 'daily', end_date: '2028-01-31'))

        expect(form.save).to be(false)
        expect(form.errors[:end_date]).to include(
          "would create more than #{described_class::MAX_OCCURRENCES} transactions"
        )
      end

      it 'does not create any transactions when the transaction is invalid' do
        form = described_class.new(attributes.merge(amount: '0', recurring: '1', frequency: 'weekly',
                                                    end_date: '2026-02-21'))

        expect { form.save }.not_to change(Transaction, :count)
        expect(form.errors[:amount]).to include('must be greater than 0')
      end
    end

    context 'when updating an existing transaction' do
      it 'ignores recurrence' do
        transaction = create(:transaction, company:)
        form = described_class.new({ recurring: '1', frequency: 'weekly', end_date: 1.month.from_now.to_date },
                                   transaction:)

        expect { form.save }.not_to change(Transaction, :count)
      end
    end
  end
end
