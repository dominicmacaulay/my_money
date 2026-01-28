# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YearOverviewPresenter do
  let(:company) { create(:company) }
  let(:presenter) { described_class.new(company) }

  describe '#years' do
    before do
      create(:transaction, company:, date: 4.years.ago)
      create(:transaction, company:, date: 2.years.ago)
      create(:transaction, company:, date: 1.year.ago)
    end

    it 'returns a list of year objects from the first transaction year to the current year' do
      expected_years = ((Time.current.year - 4)..Time.current.year).to_a.reverse

      expect(presenter.years).to eq(expected_years)
    end

    context 'when there are no transactions' do
      let(:presenter) { described_class.new(create(:company)) }

      it 'returns the current year only' do
        expect(presenter.years).to eq([Time.current.year])
      end
    end
  end
end
