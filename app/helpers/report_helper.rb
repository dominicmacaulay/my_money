# frozen_string_literal: true

module ReportHelper
  def highest_month_summary(period_total, metric)
    return '—' if period_total.nil?

    "#{period_total.name} · #{humanized_money_with_symbol(period_total.public_send(metric))}"
  end
end
