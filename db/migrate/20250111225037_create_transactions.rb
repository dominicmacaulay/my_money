class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.timestamps
      t.date :date, null: false
      t.string :description, null: false
      t.decimal :amount, null: false
      t.integer :transaction_type, null: false
      t.references :company, null: false, foreign_key: true
    end
  end
end
