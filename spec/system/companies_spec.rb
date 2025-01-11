require 'rails_helper'

RSpec.describe 'Companies', type: :system do
  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let!(:user_company) { create(:user_company, user:, company:) }

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
    expect(page).to have_content("#{name}")
  end

  it 'can be edited' do
    name = 'Updated Company'
    click_on 'Edit'
    fill_in 'Name', with: name
    click_on 'Update Company'
    expect(page).to have_content("#{name} was successfully updated")
    expect(page).to have_content("#{name}")
  end

  it 'can be destroyed' do
    click_on 'Edit'
    click_on 'Delete'
    expect(page).to have_content("#{company.name} was successfully destroyed")
  end

  it 'can be set as the current company for the app' do
    click_on "Switch to #{company.name}"
    expect(page).to have_content "Current company set to #{company.name}"
    expect(user.reload.current_company).to eql company
  end
end
