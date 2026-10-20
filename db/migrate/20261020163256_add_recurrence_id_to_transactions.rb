class AddRecurrenceIdToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :recurrence_id, :uuid
    add_index :transactions, :recurrence_id
  end
end
