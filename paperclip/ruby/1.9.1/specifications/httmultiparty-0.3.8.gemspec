# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "httmultiparty"
  s.version = "0.3.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["Johannes Wagener"]
  s.date = "2012-06-05"
  s.description = "HTTMultiParty is a thin wrapper around HTTParty to provide multipart uploads."
  s.email = ["johannes@wagener.cc"]
  s.homepage = "http://github.com/jwagener/httmultiparty"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "HTTMultiParty is a thin wrapper around HTTParty to provide multipart uploads."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0.7.3"])
      s.add_runtime_dependency(%q<multipart-post>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<fakeweb>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0.7.3"])
      s.add_dependency(%q<multipart-post>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<fakeweb>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0.7.3"])
    s.add_dependency(%q<multipart-post>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<fakeweb>, [">= 0"])
  end
end
