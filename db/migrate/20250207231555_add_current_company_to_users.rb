class AddCurrentCompanyToUsers < ActiveRecord::Migration[8.0]
  def change
    add_reference :users, :current_company, foreign_key: { to_table: :companies }, null: true
  end
end
