# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

if Rails.env.local?
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new

  require 'bundler/audit/task'
  Bundler::Audit::Task.new

  task default: %i[rubocop:autocorrect bundle:audit parallel:spec]
end
