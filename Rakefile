require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Run RSpec tests"
task default: :spec

desc "Console"
task :console do
  require "bundler/setup"
  require "clever_reach"
  require "irb"
  IRB.start(__FILE__)
end
