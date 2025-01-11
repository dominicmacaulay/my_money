require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe 'set_current_company' do
    let(:company) { create(:company) }

    context 'when the company is included in the user companies' do
      let!(:user_company) { create(:user_company, user:, company:) }

      it 'sets the current company' do
        expect(user.set_current_company(company)).to be_truthy
        expect(user.current_company).to eq(company)
      end
    end

    context 'when the company is not included in the user companies' do
      it 'does not set the current company' do
        expect(user.set_current_company(company)).to be_falsey
        expect(user.current_company).to be_nil
      end
    end
  end
end
