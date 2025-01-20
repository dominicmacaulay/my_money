# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages' do
  let(:user) { create(:user) }

  before do
    login_as user
    visit root_path
  end

  describe 'Shared header' do
    let!(:company) { create(:company) }

    context 'when user has a current company' do
      before do
        company.add_user_with_role(user, 'admin')
      end

      it 'displays the company name' do
        user.switch_current_company(company)

        page.refresh

        expect(page).to have_content(company.name)
      end
    end

    context 'when user does not have a current company' do
      it 'displays a link to set the current company' do
        expect(page).to have_link('Create Your Company')
        expect(page).to have_no_content(company.name)
      end
    end
  end
end
