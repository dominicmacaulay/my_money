module TransactionHelper
  def transaction_type_options
    Transaction.transaction_types.keys.map do |type|
      [type.titleize, type]
    end
  end
end
