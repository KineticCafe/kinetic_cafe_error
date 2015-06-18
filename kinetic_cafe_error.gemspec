# -*- encoding: utf-8 -*-
# stub: kinetic_cafe_error 1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "kinetic_cafe_error"
  s.version = "1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Austin Ziegler"]
  s.date = "2015-06-18"
  s.description = "kinetic_cafe_error provides an API-smart error base class and a DSL for\ndefining errors. Under Rails, it also provides a controller concern\n(KineticCafe::ErrorHandler) that has a useful implementation of +rescue_from+\nto handle KineticCafe::Error types.\n\nExceptions in a hierarchy can be handled in a uniform manner, including getting\nan I18n translation message with parameters, standard status values, and\nmeaningful JSON representations that can be used to establish a standard error\nrepresentations across both clients and servers."
  s.email = ["aziegler@kineticcafe.com"]
  s.extra_rdoc_files = ["Contributing.rdoc", "History.rdoc", "Licence.rdoc", "Manifest.txt", "README.rdoc", "Contributing.rdoc", "History.rdoc", "Licence.rdoc", "README.rdoc"]
  s.files = [".autotest", ".gemtest", ".travis.yml", "Contributing.rdoc", "Gemfile", "History.rdoc", "Licence.rdoc", "Manifest.txt", "README.rdoc", "Rakefile", "app/controllers/concerns/kinetic_cafe/error_handler.rb", "app/views/kinetic_cafe_error/_table.html.erb", "app/views/kinetic_cafe_error/_table.html.haml", "app/views/kinetic_cafe_error/_table.html.slim", "app/views/kinetic_cafe_error/page.html.erb", "app/views/kinetic_cafe_error/page.html.haml", "app/views/kinetic_cafe_error/page.html.slim", "config/i18n-tasks.yml.erb", "config/locales/kinetic_cafe_error.en-CA.yml", "config/locales/kinetic_cafe_error.en-UK.yml", "config/locales/kinetic_cafe_error.en-US.yml", "config/locales/kinetic_cafe_error.en.yml", "config/locales/kinetic_cafe_error.fr-CA.yml", "config/locales/kinetic_cafe_error.fr.yml", "lib/kinetic_cafe/error.rb", "lib/kinetic_cafe/error/minitest.rb", "lib/kinetic_cafe/error_dsl.rb", "lib/kinetic_cafe/error_engine.rb", "lib/kinetic_cafe/error_module.rb", "lib/kinetic_cafe/error_rspec.rb", "lib/kinetic_cafe/error_tasks.rake", "lib/kinetic_cafe_error.rb", "test/test_helper.rb", "test/test_kinetic_cafe_error.rb", "test/test_kinetic_cafe_error_dsl.rb", "test/test_kinetic_cafe_error_hierarchy.rb"]
  s.homepage = "https://github.com/KineticCafe/kinetic_cafe_error/"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--main", "README.rdoc"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = "2.4.5"
  s.summary = "kinetic_cafe_error provides an API-smart error base class and a DSL for defining errors"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 5.7"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_development_dependency(%q<hoe-doofus>, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
      s.add_development_dependency(%q<hoe-git>, ["~> 1.6"])
      s.add_development_dependency(%q<hoe-rubygems>, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-travis>, ["~> 1.2"])
      s.add_development_dependency(%q<minitest-autotest>, ["~> 1.0"])
      s.add_development_dependency(%q<minitest-bonus-assertions>, ["~> 1.0"])
      s.add_development_dependency(%q<minitest-focus>, ["~> 1.1"])
      s.add_development_dependency(%q<minitest-moar>, ["~> 0.0"])
      s.add_development_dependency(%q<minitest-stub-const>, ["~> 0.4"])
      s.add_development_dependency(%q<rack-test>, ["~> 0.6"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_development_dependency(%q<coveralls>, ["~> 0.8"])
      s.add_development_dependency(%q<hoe>, ["~> 3.13"])
    else
      s.add_dependency(%q<minitest>, ["~> 5.7"])
      s.add_dependency(%q<rdoc>, ["~> 4.0"])
      s.add_dependency(%q<hoe-doofus>, ["~> 1.0"])
      s.add_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
      s.add_dependency(%q<hoe-git>, ["~> 1.6"])
      s.add_dependency(%q<hoe-rubygems>, ["~> 1.0"])
      s.add_dependency(%q<hoe-travis>, ["~> 1.2"])
      s.add_dependency(%q<minitest-autotest>, ["~> 1.0"])
      s.add_dependency(%q<minitest-bonus-assertions>, ["~> 1.0"])
      s.add_dependency(%q<minitest-focus>, ["~> 1.1"])
      s.add_dependency(%q<minitest-moar>, ["~> 0.0"])
      s.add_dependency(%q<minitest-stub-const>, ["~> 0.4"])
      s.add_dependency(%q<rack-test>, ["~> 0.6"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.7"])
      s.add_dependency(%q<coveralls>, ["~> 0.8"])
      s.add_dependency(%q<hoe>, ["~> 3.13"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 5.7"])
    s.add_dependency(%q<rdoc>, ["~> 4.0"])
    s.add_dependency(%q<hoe-doofus>, ["~> 1.0"])
    s.add_dependency(%q<hoe-gemspec2>, ["~> 1.1"])
    s.add_dependency(%q<hoe-git>, ["~> 1.6"])
    s.add_dependency(%q<hoe-rubygems>, ["~> 1.0"])
    s.add_dependency(%q<hoe-travis>, ["~> 1.2"])
    s.add_dependency(%q<minitest-autotest>, ["~> 1.0"])
    s.add_dependency(%q<minitest-bonus-assertions>, ["~> 1.0"])
    s.add_dependency(%q<minitest-focus>, ["~> 1.1"])
    s.add_dependency(%q<minitest-moar>, ["~> 0.0"])
    s.add_dependency(%q<minitest-stub-const>, ["~> 0.4"])
    s.add_dependency(%q<rack-test>, ["~> 0.6"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.7"])
    s.add_dependency(%q<coveralls>, ["~> 0.8"])
    s.add_dependency(%q<hoe>, ["~> 3.13"])
  end
end
