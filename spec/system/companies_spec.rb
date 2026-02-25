# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Companies' do
  let!(:company) { create(:company) }
  let(:other_company) { create(:company) }
  let(:user) { create(:user, companies: [company, other_company]) }

  before do
    login_as user
    visit root_path
    click_on 'account_circle'
    click_on 'Companies'
  end

  it 'can be created' do
    name = 'New Company'
    click_on 'New Company'
    fill_in 'Name', with: name
    click_on 'Create Company'

    expect(page).to have_content("#{name} was successfully created")
    expect(page).to have_content(name.to_s)

    company = Company.all.max_by(&:id)
    expect(company.name).to eq(name)
    expect(company.users).to include(user)
    expect(company.user_companies.find_by(user: user)).to be_admin
  end

  it 'can be edited' do
    name = 'Updated Company'
    within data_test(company.id) do
      click_on 'Edit'
    end
    fill_in 'Name', with: name
    click_on 'Update Company'

    expect(page).to have_content("#{name} was successfully updated")
    expect(page).to have_content(name.to_s)

    company.reload
    expect(company.name).to eq(name)
  end

  it 'can be destroyed', :js do
    expect do
      within data_test(company.id) do
        click_on 'Delete'
      end
      click_on "Yes, I'm Sure"
      expect(page).to have_content("#{company.name} was successfully destroyed")
    end.to change(Company, :count).by(-1)
  end

  it 'can be set as the current company for the app' do
    click_on "Switch to #{other_company.name}"
    expect(page).to have_content "Current company set to #{other_company.name}"
  end
end
