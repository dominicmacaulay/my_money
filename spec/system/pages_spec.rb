require 'rails_helper'

RSpec.describe 'Pages', type: :system do
  let(:user) { create(:user) }

  before do
    login_as user
    visit root_path
  end

  describe 'Shared header' do
    let!(:company) { create(:company) }

    context 'when user has a current company' do
      let!(:user_company) { create(:user_company, user:, company:) }

      it 'displays the company name' do
        user.set_current_company(company)

        page.refresh

        expect(page).to have_content(company.name)
      end
    end

    context 'when user does not have a current company' do
      it 'displays a link to set the current company' do
        expect(page).to have_link('Create Your Company')
        expect(page).not_to have_content(company.name)
      end
    end
  end
end
