# frozen_string_literal: true

namespace :code do
  task :brakeman do # rubocop:disable Rails/RakeEnvironment
    sh 'bundle exec brakeman -quiet'
  end
end
