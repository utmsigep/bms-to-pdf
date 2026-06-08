require "rake/testtask"
require "prawn"
require "prawn/table"

ENV["MT_NO_PLUGINS"] = "1"

Rake::TestTask.new do |t|
  t.pattern = "test/**/*_test.rb"
  t.libs << "test"
end

task default: :test
