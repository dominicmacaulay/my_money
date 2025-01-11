class AddCurrentCompanyToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :current_company_id, :bigint
    add_foreign_key :users, :companies, column: :current_company_id
  end
end
