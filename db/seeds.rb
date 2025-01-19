require 'factory_bot_rails'

# Including FactoryBot methods
include FactoryBot::Syntax::Methods

if Category.any?
  puts "Categories already exist. Skipping seeding..."
  return
end

# Seed Categories and Subcategories
puts "Seeding Categories and Subcategories..."

create(:category, name: 'Advertising')
create(:category, name: 'Car and truck expenses')
create(:category, name: 'Commissions and fees, contract labor')
create(:category, name: 'Depletion')
create(:category, name: 'Depreciation and section 179 expense deduction')
create(:category, name: 'Employee benefit programs')
create(:category, name: 'Insurance, interest')
create(:category, name: 'Legal and professional services')
create(:category, name: 'Office expense')
create(:category, name: 'Pension and profit-sharing plans')
create(:category, name: 'Rent or lease')
create(:category, name: 'Repairs and maintenance')
create(:category, name: 'Supplies')
create(:category, name: 'Taxes and licenses')
create(:category, name: 'Travel and meals')
create(:category, name: 'Utilities')
create(:category, name: 'Wages')

puts "Seeding completed!"
