# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:user) { create(:user) }

  describe 'switch_current_company' do
    let(:company) { create(:company) }

    context 'when the company is included in the user companies' do
      before do
        create(:user_company, user:, company:, role: 'admin')
      end

      it 'sets the current company' do
        expect(user.switch_current_company(company)).to be_truthy
        expect(user.current_company).to eq(company)
      end
    end

    context 'when the company is not included in the user companies' do
      it 'does not set the current company' do
        expect(user.switch_current_company(company)).to be_falsey
        expect(user.current_company).to be_nil
      end
    end
  end

  describe '#destroy_company?' do
    let(:company) { create(:company) }

    context 'when the user is an admin' do
      before do
        create(:user_company, user:, company:, role: 'admin')
      end

      it 'returns true' do
        expect(user.destroy_company?(company)).to be_truthy # rubocop:disable RSpec/PredicateMatcher
      end
    end

    context 'when the user is not an admin' do
      before do
        create(:user_company, user:, company:, role: 'member')
      end

      it 'returns false' do
        expect(user.destroy_company?(company)).to be_falsey # rubocop:disable RSpec/PredicateMatcher
      end
    end

    context 'when the user does not belong to that company' do
      it 'returns false' do
        expect(user.destroy_company?(company)).to be_falsey # rubocop:disable RSpec/PredicateMatcher
      end
    end
  end

  describe '#handle_company_destruction' do
    let(:company) { create(:company) }

    before do
      create(:user_company, user:, company:, role: 'admin')
    end

    context 'when the user has another company' do
      let(:other_company) { create(:company) }

      before do
        create(:user_company, user:, company: other_company, role: 'member')
      end

      it 'sets the current company to the first company that is not the destroyed company' do
        user.handle_company_destruction(company)
        expect(user.current_company).to eq(other_company)
      end
    end

    context 'when the user does not have another company' do
      it 'sets the current company to nil' do
        user.handle_company_destruction(company)
        expect(user.current_company).to be_nil
      end
    end
  end
end
