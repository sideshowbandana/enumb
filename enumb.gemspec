# -*- encoding: utf-8 -*-
require File.expand_path("../lib/enumb/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "enumb"
  s.version     = Enumb::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kyle Barton"]
  s.email       = ["kyle.barton@mylookout.com"]
  s.homepage    = "http://github.com/sideshowbandana/enumb"
  s.summary     = "Create database agnostic enum columns"
  s.description = "Enub will add attr_accessor methods for encoding/decoding enum values into integers"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "enumb"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "activerecord", ">= 3.0.0"
  s.add_dependency('eigenclass', ['>= 1.1.1'])
  s.add_dependency('mocha', ['>= 0.9.8'])
  
  s.files        = `git ls-files`.split("\n")
  s.executables  = s.files.map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.test_files  = s.files.map{|f| f =~ /^(test\/.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
