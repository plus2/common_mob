# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'common_mob/version'
 
Gem::Specification.new do |s|
  s.name        = "angry_mob_common_targets"
  s.version     = CommonMob::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lachie Cox"]
  s.email       = ["lachie.cox@plus2.com.au"]
  s.homepage    = "http://github.com/plus2/common_mob"
  s.summary     = "Common targets to use with AngryMob"
  s.description = "AngryMob Common Targets are a set of essential, reusable targets to get you started with AngryMob."
 
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "angry_mob_common_targets"
 
  # s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{acts,lib,targets,vendor}/**/*") + %w(LICENSE README.md)
  s.executables  = []
  # s.require_path = 'lib'
  
end
