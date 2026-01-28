# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YearOverviewPolicy do
  let(:user) { create(:user) }
  let(:policy) { described_class }

  permissions :index? do
    it 'allows access to all users' do
      expect(policy).to permit(user, :year_overview)
    end
  end
end
