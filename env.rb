# frozen_string_literal: true

# Local override
dotenv = File.expand_path('.env_overrides.rb', __dir__)
require dotenv if File.exist?(dotenv)

# env.rb
ENV['PORT'] ||= '3000' # Default to 3000 if not set
