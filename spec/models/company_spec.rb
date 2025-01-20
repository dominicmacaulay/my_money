# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company do
  let(:company) { create(:company) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe '#add_user_with_role' do
    it 'adds a user with a role' do
      user = create(:user)
      company.add_user_with_role(user, 'admin')
      expect(company.users).to include(user)

      user_company = company.user_companies.first
      expect(user_company.role).to eq('admin')
    end
  end
end
