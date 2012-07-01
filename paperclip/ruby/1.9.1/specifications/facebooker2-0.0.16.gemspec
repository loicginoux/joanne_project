# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "facebooker2"
  s.version = "0.0.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mike Mangino"]
  s.date = "2011-12-12"
  s.description = "Facebook Connect integration library for ruby and rails"
  s.email = "mmangino@elevatedrails.com"
  s.homepage = "http://developers.facebook.com/docs/api"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Facebook Connect integration library for ruby and rails"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mogli>, [">= 0.0.33"])
      s.add_runtime_dependency(%q<ruby-hmac>, [">= 0"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_development_dependency(%q<rspec>, ["~> 1.3.1"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 1.3.1"])
      s.add_development_dependency(%q<rails>, ["~> 2.3.10"])
      s.add_development_dependency(%q<json>, ["~> 1.4.0"])
    else
      s.add_dependency(%q<mogli>, [">= 0.0.33"])
      s.add_dependency(%q<ruby-hmac>, [">= 0"])
      s.add_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_dependency(%q<rspec>, ["~> 1.3.1"])
      s.add_dependency(%q<rspec-rails>, ["~> 1.3.1"])
      s.add_dependency(%q<rails>, ["~> 2.3.10"])
      s.add_dependency(%q<json>, ["~> 1.4.0"])
    end
  else
    s.add_dependency(%q<mogli>, [">= 0.0.33"])
    s.add_dependency(%q<ruby-hmac>, [">= 0"])
    s.add_dependency(%q<rake>, ["~> 0.8.7"])
    s.add_dependency(%q<rspec>, ["~> 1.3.1"])
    s.add_dependency(%q<rspec-rails>, ["~> 1.3.1"])
    s.add_dependency(%q<rails>, ["~> 2.3.10"])
    s.add_dependency(%q<json>, ["~> 1.4.0"])
  end
end
