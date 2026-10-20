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
        form = new_form

        expect { form.save }.to change(Transaction, :count).by(1)
        expect(form.transaction).to be_persisted
      end
    end

    context 'when recurring' do
      it 'creates a transaction for each occurrence through the end date' do
        form = new_form(recurring: '1', frequency: 'weekly', end_date: '2026-02-21')

        expect { form.save }.to change(Transaction, :count).by(4)
        expect(company.transactions.order(:date).pluck(:date)).to eq(
          [Date.new(2026, 1, 31), Date.new(2026, 2, 7), Date.new(2026, 2, 14), Date.new(2026, 2, 21)]
        )
        expect(company.transactions.pluck(:description).uniq).to eq(['Rent'])
        expect(company.transactions.distinct.pluck(:recurrence_id)).to contain_exactly(be_present)
      end

      it 'copies every attribute but the date and sets timestamps on the bulk-inserted occurrences' do
        form = new_form(recurring: '1', frequency: 'daily', end_date: '2026-02-02')

        form.save

        expect(form.saved_count).to eq(3)
        transactions = company.transactions.order(:date)
        expect(transactions.map(&:amount).uniq).to eq([Money.new(2500, 'USD')])
        expect(transactions.map(&:transaction_type).uniq).to eq(['income'])
        expect(transactions.pluck(:created_at, :updated_at).flatten).to all(be_present)
      end

      it 'keeps monthly occurrences anchored to the start day' do
        form = new_form(recurring: '1', frequency: 'monthly', end_date: '2026-04-30')

        form.save

        expect(company.transactions.order(:date).pluck(:date)).to eq(
          [Date.new(2026, 1, 31), Date.new(2026, 2, 28), Date.new(2026, 3, 31), Date.new(2026, 4, 30)]
        )
      end

      it 'requires a frequency and end date' do
        form = new_form(recurring: '1')

        expect(form.save).to be(false)
        expect(form.errors[:frequency]).to include('is not included in the list')
        expect(form.errors[:end_date]).to include("can't be blank")
      end

      it 'requires the end date to be after the transaction date' do
        form = new_form(recurring: '1', frequency: 'daily', end_date: '2026-01-31')

        expect(form.save).to be(false)
        expect(form.errors[:end_date]).to include('must be after the transaction date')
      end

      it 'limits how many transactions can be created at once' do
        form = new_form(recurring: '1', frequency: 'daily', end_date: '2028-01-31')

        expect(form.save).to be(false)
        expect(form.errors[:end_date]).to include(
          "would create more than #{described_class::MAX_OCCURRENCES} transactions"
        )
      end

      it 'does not create any transactions when the transaction is invalid' do
        form = new_form(amount: '0', recurring: '1', frequency: 'weekly', end_date: '2026-02-21')

        expect { form.save }.not_to change(Transaction, :count)
        expect(form.errors[:amount]).to include('must be greater than 0')
      end
    end

    context 'when updating a recurring transaction' do
      let(:recurrence_id) { SecureRandom.uuid }
      let!(:past) { create(:transaction, company:, recurrence_id:, date: Date.new(2026, 1, 1), amount: '10.00') }
      let!(:current) { create(:transaction, company:, recurrence_id:, date: Date.new(2026, 2, 1), amount: '10.00') }
      let!(:future) { create(:transaction, company:, recurrence_id:, date: Date.new(2026, 3, 1), amount: '10.00') }

      it 'updates only this occurrence by default' do
        described_class.new(current, amount: '20.00').save

        expect([past, current, future].map { |t| t.reload.amount.to_s }).to eq(%w[10.00 20.00 10.00])
      end

      it "copies this occurrence's state onto later ones, keeping their own dates and descriptions" do
        described_class.new(current, amount: '20.00', date: '2026-02-03', description: 'Gym', occurrences: 'future')
                       .save

        [past, current, future].each(&:reload)
        expect([past, current, future].map { |t| t.amount.to_s }).to eq(%w[10.00 20.00 20.00])
        expect([past, current, future].map(&:date)).to eq(
          [Date.new(2026, 1, 1), Date.new(2026, 2, 3), Date.new(2026, 3, 1)]
        )
        expect(current.description).to eq('Gym')
        expect(future.description).not_to eq('Gym')
      end

      it 'brings later occurrences that were edited on their own back in line with this one' do
        category = create(:category)
        future.update!(transaction_type: 'expense', categorizable: category, amount: '99.00')

        described_class.new(current, occurrences: 'future').save

        future.reload
        expect(future).to be_income
        expect(future.categorizable).to be_nil
        expect(future.amount.to_s).to eq('10.00')
        expect(future).to be_valid
      end

      it 'bumps updated_at on the later occurrences' do
        expect do
          described_class.new(current, amount: '20.00', occurrences: 'future').save
        end.to(change { future.reload.updated_at })
      end
    end

    context 'when updating an existing transaction' do
      it 'ignores recurrence' do
        transaction = create(:transaction, company:)
        form = described_class.new(transaction, recurring: '1', frequency: 'weekly', end_date: 1.month.from_now.to_date)

        expect { form.save }.not_to change(Transaction, :count)
      end
    end
  end

  def new_form(overrides = {})
    described_class.new(Transaction.new, attributes.merge(overrides))
  end
end
