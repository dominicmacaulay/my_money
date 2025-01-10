require 'rails_helper'

RSpec.describe 'Companies', type: :system do
  let(:user) { create(:user) }

  before do
    login_as user
    visit root_path
  end

  it 'can be created' do
    click_on 'account_circle'
    click_on 'companies'

    expect(page).to have_content('Companies')
  end
end
