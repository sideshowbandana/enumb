require "rubygems"
require 'bundler'
require 'rake'
require 'rake/testtask'
Bundler::GemHelper.install_tasks

namespace :test do 
  Rake::TestTask.new(:all) do |t|
    t.libs << "test"
    t.test_files = FileList['test/*test.rb']
    t.verbose = true
  end
end

task :default => 'test:all'
