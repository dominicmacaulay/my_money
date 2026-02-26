# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:company) { create(:company) }
  let(:user) { create(:user, companies: [company]) }

  describe '#admin_for_company?' do
    context 'when the user is an admin' do
      it 'returns true' do
        expect(user.admin_for_company?(company)).to be_truthy # rubocop:disable RSpec/PredicateMatcher
      end
    end

    context 'when the user is not an admin' do
      before do
        user_company = user.user_companies.find_by(company: company)
        user_company.update(role: 'member')
      end

      it 'returns false' do
        expect(user.admin_for_company?(company)).to be_falsey # rubocop:disable RSpec/PredicateMatcher
      end
    end

    context 'when the user does not belong to that company' do
      let(:other_company) { create(:company) }

      it 'returns false' do
        expect(user.admin_for_company?(other_company)).to be_falsey # rubocop:disable RSpec/PredicateMatcher
      end
    end
  end
end
