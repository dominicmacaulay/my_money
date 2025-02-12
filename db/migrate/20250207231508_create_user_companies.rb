class CreateUserCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :user_companies do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.timestamps

      t.index [ :user_id, :company_id ], unique: true
    end
  end
end
