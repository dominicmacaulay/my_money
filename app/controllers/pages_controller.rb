# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    authorize :page, :home?
  end
end
