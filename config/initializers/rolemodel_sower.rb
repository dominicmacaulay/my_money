# frozen_string_literal: true

RolemodelSower.setup do |config|
  # Available Adapters :yaml, :csv, :tsv, :json
  config.adapter = :json

  # Path to the directory containing the seed data files
  config.data_path = 'db/rolemodel_sower_data'
end
