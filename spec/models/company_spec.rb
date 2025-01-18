# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company do
  let(:company) { create(:company) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
