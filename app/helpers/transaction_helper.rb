# frozen_string_literal: true

module TransactionHelper
  def transaction_type_options
    Transaction.transaction_types.keys.map do |type|
      [type.humanize, type]
    end
  end

  def categorizable_options
    categories = current_company.subcategories.to_a.concat(Category.all)
    categories.map do |category|
      name = category.name
      name.concat(" (Subcategory of #{category.category_name})") unless category.is_a?(Category)
      [
        name,
        category.to_signed_global_id
      ]
    end
  end

  def selected_categorizable_option(transaction, options)
    options.find do |option|
      option.last == transaction.categorizable&.to_signed_global_id
    end
  end
end
