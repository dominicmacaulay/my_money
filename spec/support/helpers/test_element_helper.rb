# frozen_string_literal: true

module TestElementHelper
  include ActionView::RecordIdentifier

  def data_test(name)
    if name.respond_to?(:id)
      "[data-test-id='#{dom_id(name)}']"
    else
      "[data-test-id='#{name}']"
    end
  end
end
