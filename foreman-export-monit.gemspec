# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "foreman-export-monit/version"

Gem::Specification.new do |s|
  s.name        = "foreman-export-monit"
  s.version     = ForemanExportMonit::VERSION
  s.authors     = ["Max Horbul", "Brad Gessler"]
  s.email       = ["max.horbul@livingsocial.com", "brad@bradgessler.com"]
  s.homepage    = ""
  s.summary     = %q{Export monit scripts from Foreman}
  s.description = %q{Exports monit scripts fromm Foreman}

  s.rubyforge_project = "foreman-export-monit"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "foreman"
  s.add_development_dependency "rspec"
end
