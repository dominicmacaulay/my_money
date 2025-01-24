# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PagePolicy do
  subject(:page_policy) { described_class }

  let(:user) { create(:user) }

  permissions :home? do
    it 'grants access to home' do
      expect(page_policy).to permit(user, :page)
    end
  end
end
