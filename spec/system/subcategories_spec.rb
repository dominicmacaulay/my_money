# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Subcategories' do
  let(:user) { create(:user) }
  let(:company) { create(:company, users: [user]) }
  let!(:category) { create(:category) }

  before do
    user.switch_current_company(company)

    login_as user
    visit root_path
  end

  context 'when being created' do
    before do
      click_on 'Subcategories'
      click_on 'New Subcategory'
    end

    it 'can be created' do
      name = 'New Subcategory'

      fill_in 'Name', with: name
      select category.name, from: 'Category'
      click_on 'Create Subcategory'

      expect(page).to have_content("#{name} was successfully created")
      expect(page).to have_content(name.to_s)

      subcategory = Subcategory.all.max_by(&:id)
      expect(subcategory.name).to eq(name)
      expect(subcategory.category).to eq(category)
      expect(subcategory.company).to eq(company)
    end

    it 'does not show a delete button' do
      expect(page).to have_content('Create Subcategory')
      expect(page).to have_no_content('Delete')
    end
  end

  context 'when being viewed', :js do
    let!(:subcategory) { create(:subcategory, category:, company:) }
    let!(:category2) { create(:category) }

    before do
      click_on 'Subcategories'

      click_on 'View'
    end

    it 'can be edited' do
      name = 'Updated Subcategory'

      select category2.name, from: 'Category'
      fill_in 'Name', with: name
      click_on 'Update Subcategory'

      expect(page).to have_content("#{name} was successfully updated")
      expect(page).to have_content(name.to_s)

      subcategory.reload
      expect(subcategory.name).to eq(name)
      expect(subcategory.category).to eq(category2)
    end

    it 'can be destroyed' do
      expect do
        click_on 'Delete'
        click_on "Yes, I'm Sure"
        expect(page).to have_content('Subcategory was successfully destroyed')
      end.to change(Subcategory, :count).by(-1)
    end
  end
end
