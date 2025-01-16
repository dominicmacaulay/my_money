# frozen_string_literal: true

module ApplicationHelper
  def submit_button(model, label = nil, form: nil, **options, &)
    model = model.last if model.is_a?(Array)
    action = options.delete(:action) || (model.respond_to?(:persisted?) && model.persisted? ? :edit : :new)
    form ||= dom_id(model, action)

    button_tag(label, form:, **options, &)
  end
end
