class RemoveCurrentCompanyFromUser < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :current_company_id, :bigint
  end
end
