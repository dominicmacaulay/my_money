class AddCategorizableToTransactions < ActiveRecord::Migration[8.0]
  def change
    add_reference :transactions, :categorizable, polymorphic: true
  end
end
