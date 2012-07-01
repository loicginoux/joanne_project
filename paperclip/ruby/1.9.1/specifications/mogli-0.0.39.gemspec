# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mogli"
  s.version = "0.0.39"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Mangino"]
  s.date = "2012-06-22"
  s.description = "Simple library for accessing the Facebook Open Graph API"
  s.email = "mmangino@elevatedrails.com"
  s.homepage = "http://developers.facebook.com/docs/api"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Open Graph Library for Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hashie>, [">= 1.1.0"])
      s.add_runtime_dependency(%q<httmultiparty>, [">= 0.3.6"])
      s.add_runtime_dependency(%q<httparty>, [">= 0.4.3"])
      s.add_runtime_dependency(%q<multi_json>, ["< 1.4", ">= 1.0.3"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<hashie>, [">= 1.1.0"])
      s.add_dependency(%q<httmultiparty>, [">= 0.3.6"])
      s.add_dependency(%q<httparty>, [">= 0.4.3"])
      s.add_dependency(%q<multi_json>, ["< 1.4", ">= 1.0.3"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<hashie>, [">= 1.1.0"])
    s.add_dependency(%q<httmultiparty>, [">= 0.3.6"])
    s.add_dependency(%q<httparty>, [">= 0.4.3"])
    s.add_dependency(%q<multi_json>, ["< 1.4", ">= 1.0.3"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
