# frozen_string_literal: true

module TransactionHelper
  def transaction_type_options
    Transaction.transaction_types.keys.map do |type|
      [type.titleize, type]
    end
  end

  def categorizable_options
    # categories = Category.all.concat current_company.categories.to_a # THIS WILL BE THE EVENTUAL CHANGES
    categories = Category.all
    categories.map do |category|
      [category.name, category.to_signed_global_id]
    end
  end

  def selected_categorizable_option(transaction, options)
    options.find do |option|
      option.last == transaction.categorizable&.to_signed_global_id
    end
  end
end
