# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "cucumber/rake/task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
Cucumber::Rake::Task.new

task default: %i[spec cucumber rubocop]

namespace :docker do
  desc "Build the Docker container"
  task :build do
    context = File.dirname(__FILE__)
    system("docker build -t jcarlson/teleport #{context}")
  end

  desc "Run the Docker container"
  task run: [:build] do
    system("docker run --privileged --network host -it jcarlson/teleport")
  end
end
