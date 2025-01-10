require 'rails_helper'

RSpec.describe 'Companies', type: :system do
  include Warden::Test::Helpers
  let(:user) { create(:user) }

  before do
    login_as user
    visit root_path
  end

  it 'shows the companies' do
    expect(page).to have_content('Companies')
  end
end
