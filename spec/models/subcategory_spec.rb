# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subcategory do
  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should belong_to(:category) }
    it { should have_many(:transactions).dependent(:destroy) }
  end

  describe 'delegations' do
    it { should delegate_method(:name).to(:category).with_prefix }
  end
end
