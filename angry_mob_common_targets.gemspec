# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "angry_mob_common_targets/version"

Gem::Specification.new do |s|
  s.name        = "angry_mob_common_targets"
  s.version     = AngryMobCommonTargets::VERSION
  s.authors     = ["Lachie Cox"]
  s.email       = ["lachie.cox@plus2.com.au"]
  s.homepage    = "http://github.com/plus2/common_mob"
  s.summary     = %q{Common targets to use with AngryMob}
  s.description = %q{AngryMob Common Targets are a set of essential, reusable targets to get you started with AngryMob}

  s.rubyforge_project = "angry_mob_common_targets"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
