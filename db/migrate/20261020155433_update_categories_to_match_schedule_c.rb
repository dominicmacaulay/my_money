# frozen_string_literal: true

# Aligns categories with the expense lines in Part II of IRS Schedule C.
# Combined categories are renamed to their first line item so existing
# transactions and subcategories keep pointing at a valid category.
class UpdateCategoriesToMatchScheduleC < ActiveRecord::Migration[8.1]
  class MigrationCategory < ActiveRecord::Base
    self.table_name = 'categories'
  end

  RENAMES = {
    'Commissions and fees, contract labor' => 'Commissions and fees',
    'Insurance, interest' => 'Insurance (other than health)'
  }.freeze

  ADDITIONS = ['Contract labor', 'Interest', 'Other expenses'].freeze

  def up
    RENAMES.each { |old_name, new_name| rename(old_name, new_name) }
    ADDITIONS.each { |name| MigrationCategory.find_or_create_by!(name:) }
  end

  def down
    MigrationCategory.where(name: ADDITIONS).find_each do |category|
      if category_in_use?(category)
        raise ActiveRecord::IrreversibleMigration, "Category '#{category.name}' has transactions or subcategories"
      end

      category.destroy!
    end

    RENAMES.each { |old_name, new_name| rename(new_name, old_name) }
  end

  private

  def rename(from, to)
    MigrationCategory.where(name: from).find_each { |category| category.update!(name: to) }
  end

  def category_in_use?(category)
    select_value(<<~SQL.squish).present?
      SELECT 1 FROM transactions WHERE categorizable_type = 'Category' AND categorizable_id = #{category.id}
      UNION ALL
      SELECT 1 FROM subcategories WHERE category_id = #{category.id}
      LIMIT 1
    SQL
  end
end
