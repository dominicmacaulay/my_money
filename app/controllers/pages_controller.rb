# frozen_string_literal: true

class PagesController < ApplicationController
  helper_method :welcome_messages

  def home
    authorize :page, :home?

    @year_income = (current_company&.income_for_year(Date.current.year)&./ 100) || 0
    @year_expense = (current_company&.expense_for_year(Date.current.year)&./ 100) || 0
  end

  private

  def welcome_messages
    [
      "Easily manage your company's finances with our simple solution. Track your income and expenses all in one place, and create personalized expense categories as subcategories of the IRS official categories. Assign your transactions to these new subcategories for better organization.", # rubocop:disable Layout/LineLength
      "Get a yearly summary of your income, expenses, and overall balance, along with insights into your best and worst months. You'll also receive a detailed breakdown of your taxes on a yearly and quarterly basis. As you enter transactions, we'll predict your company's total profit for the year and estimate your tax liability.", # rubocop:disable Layout/LineLength
      "Once you've created your first company, you can access all these features from the dropdown menu at the top right corner of the page.", # rubocop:disable Layout/LineLength
      'Ready to get started? Click the button at the top right corner to create your first company!'
    ]
  end
end
