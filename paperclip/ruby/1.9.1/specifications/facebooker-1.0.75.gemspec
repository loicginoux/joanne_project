# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "facebooker"
  s.version = "1.0.75"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chad Fowler", "Patrick Ewing", "Mike Mangino", "Shane Vitarana", "Corey Innis", "Mike Mangino"]
  s.date = "2010-08-20"
  s.description = "Facebooker is a Ruby wrapper over the Facebook[http://facebook.com] {REST API}[http://wiki.developers.facebook.com/index.php/API].  Its goals are:\n\n* Idiomatic Ruby\n* No dependencies outside of the Ruby standard library (This is true with Rails 2.1. Previous Rails versions require the JSON gem)\n* Concrete classes and methods modeling the Facebook data, so it's easy for a Rubyist to understand what's available\n* Well tested"
  s.email = ["chad@chadfowlwer.com", "", "", "", "", "mmangino@elevatedrails.com"]
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "COPYING.rdoc", "README.rdoc", "TODO.rdoc"]
  s.files = ["Manifest.txt", "CHANGELOG.rdoc", "COPYING.rdoc", "README.rdoc", "TODO.rdoc"]
  s.homepage = "http://facebooker.rubyforge.org"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "facebooker"
  s.rubygems_version = "1.8.10"
  s.summary = "Facebooker is a Ruby wrapper over the Facebook[http://facebook.com] {REST API}[http://wiki.developers.facebook.com/index.php/API]"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json_pure>, [">= 1.0.0"])
      s.add_development_dependency(%q<hoe>, [">= 2.4.0"])
    else
      s.add_dependency(%q<json_pure>, [">= 1.0.0"])
      s.add_dependency(%q<hoe>, [">= 2.4.0"])
    end
  else
    s.add_dependency(%q<json_pure>, [">= 1.0.0"])
    s.add_dependency(%q<hoe>, [">= 2.4.0"])
  end
end
