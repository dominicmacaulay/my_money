require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { create(:company) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(company).to be_valid
    end

    it 'is invalid without a name' do
      company.name = nil
      expect(company).to be_invalid
    end
  end
end
