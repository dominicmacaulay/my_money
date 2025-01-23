class MakeSubcategoriesBelongToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_reference :subcategories, :company, null: false, foreign_key: true
  end
end
