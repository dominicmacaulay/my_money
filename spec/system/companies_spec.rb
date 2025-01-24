# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Companies' do
  let(:user) { create(:user) }
  let(:company) { create(:company) }

  before do
    company.users << user

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
    click_on 'Edit'
    fill_in 'Name', with: name
    click_on 'Update Company'

    expect(page).to have_content("#{name} was successfully updated")
    expect(page).to have_content(name.to_s)

    company.reload
    expect(company.name).to eq(name)
  end

  it 'can be destroyed', :js do
    expect do
      accept_confirm do
        click_on 'Delete'
      end
      expect(page).to have_content("#{company.name} was successfully destroyed")
    end.to change(Company, :count).by(-1)
  end

  it 'can be set as the current company for the app' do
    click_on "Switch to #{company.name}"
    expect(page).to have_content "Current company set to #{company.name}"
    expect(user.reload.current_company).to eql company
  end
end
