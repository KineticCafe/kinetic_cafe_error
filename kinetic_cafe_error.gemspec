# -*- encoding: utf-8 -*-
# stub: kinetic_cafe_error 1.11 ruby lib

Gem::Specification.new do |s|
  s.name = "kinetic_cafe_error".freeze
  s.version = "1.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze, "Jero Sutlovic".freeze, "Ravi Desai".freeze]
  s.date = "2016-05-24"
  s.description = "kinetic_cafe_error provides an API-smart error base class and a DSL for\ndefining errors. Under Rails, it also provides a controller concern\n(KineticCafe::ErrorHandler) that has a useful implementation of +rescue_from+\nto handle KineticCafe::Error types.\n\nExceptions in a hierarchy can be handled in a uniform manner, including getting\nan I18n translation message with parameters, standard status values, and\nmeaningful JSON representations that can be used to establish a standard error\nrepresentations across both clients and servers.".freeze
  s.email = ["aziegler@kineticcafe.com".freeze, "jsutlovic@kineticcafe.com".freeze, "rdesai@kineticcafe.com".freeze]
  s.extra_rdoc_files = ["Contributing.md".freeze, "History.md".freeze, "Licence.md".freeze, "Manifest.txt".freeze, "README.rdoc".freeze]
  s.files = ["Contributing.md".freeze, "History.md".freeze, "Licence.md".freeze, "Manifest.txt".freeze, "README.rdoc".freeze, "Rakefile".freeze, "app/controllers/concerns/kinetic_cafe/error_handler.rb".freeze, "app/views/kinetic_cafe_error/_table.html.erb".freeze, "app/views/kinetic_cafe_error/_table.html.haml".freeze, "app/views/kinetic_cafe_error/_table.html.slim".freeze, "app/views/kinetic_cafe_error/page.html.erb".freeze, "app/views/kinetic_cafe_error/page.html.haml".freeze, "app/views/kinetic_cafe_error/page.html.slim".freeze, "config/i18n-tasks.yml.erb".freeze, "config/locales/kinetic_cafe_error.en-CA.yml".freeze, "config/locales/kinetic_cafe_error.en-UK.yml".freeze, "config/locales/kinetic_cafe_error.en-US.yml".freeze, "config/locales/kinetic_cafe_error.en.yml".freeze, "config/locales/kinetic_cafe_error.fr-CA.yml".freeze, "config/locales/kinetic_cafe_error.fr.yml".freeze, "lib/kinetic_cafe/error.rb".freeze, "lib/kinetic_cafe/error/minitest.rb".freeze, "lib/kinetic_cafe/error_dsl.rb".freeze, "lib/kinetic_cafe/error_engine.rb".freeze, "lib/kinetic_cafe/error_module.rb".freeze, "lib/kinetic_cafe/error_rspec.rb".freeze, "lib/kinetic_cafe/error_tasks.rake".freeze, "lib/kinetic_cafe/error_tasks.rb".freeze, "lib/kinetic_cafe_error.rb".freeze, "test/test_helper.rb".freeze, "test/test_kinetic_cafe_error.rb".freeze, "test/test_kinetic_cafe_error_dsl.rb".freeze, "test/test_kinetic_cafe_error_hierarchy.rb".freeze]
  s.homepage = "https://github.com/KineticCafe/kinetic_cafe_error/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.rdoc".freeze]
  s.required_ruby_version = Gem::Requirement.new("~> 2.1".freeze)
  s.rubygems_version = "2.6.4".freeze
  s.summary = "kinetic_cafe_error provides an API-smart error base class and a DSL for defining errors".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.9"])
      s.add_development_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.1"])
      s.add_development_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
      s.add_development_dependency(%q<hoe-git>.freeze, ["~> 1.6"])
      s.add_development_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
      s.add_development_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<minitest-bonus-assertions>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
      s.add_development_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
      s.add_development_dependency(%q<minitest-stub-const>.freeze, ["~> 0.4"])
      s.add_development_dependency(%q<rack-test>.freeze, ["~> 0.6"])
      s.add_development_dependency(%q<rake>.freeze, ["< 12", ">= 10.0"])
      s.add_development_dependency(%q<i18n-tasks>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<i18n-tasks-csv>.freeze, ["~> 1.0"])
      s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.32"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_development_dependency(%q<coveralls>.freeze, ["~> 0.8"])
      s.add_development_dependency(%q<hoe>.freeze, ["~> 3.15"])
    else
      s.add_dependency(%q<minitest>.freeze, ["~> 5.9"])
      s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
      s.add_dependency(%q<appraisal>.freeze, ["~> 2.1"])
      s.add_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
      s.add_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
      s.add_dependency(%q<hoe-git>.freeze, ["~> 1.6"])
      s.add_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
      s.add_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
      s.add_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
      s.add_dependency(%q<minitest-bonus-assertions>.freeze, ["~> 1.0"])
      s.add_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
      s.add_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
      s.add_dependency(%q<minitest-stub-const>.freeze, ["~> 0.4"])
      s.add_dependency(%q<rack-test>.freeze, ["~> 0.6"])
      s.add_dependency(%q<rake>.freeze, ["< 12", ">= 10.0"])
      s.add_dependency(%q<i18n-tasks>.freeze, ["~> 0.8"])
      s.add_dependency(%q<i18n-tasks-csv>.freeze, ["~> 1.0"])
      s.add_dependency(%q<rubocop>.freeze, ["~> 0.32"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
      s.add_dependency(%q<coveralls>.freeze, ["~> 0.8"])
      s.add_dependency(%q<hoe>.freeze, ["~> 3.15"])
    end
  else
    s.add_dependency(%q<minitest>.freeze, ["~> 5.9"])
    s.add_dependency(%q<rdoc>.freeze, ["~> 4.0"])
    s.add_dependency(%q<appraisal>.freeze, ["~> 2.1"])
    s.add_dependency(%q<hoe-doofus>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hoe-gemspec2>.freeze, ["~> 1.1"])
    s.add_dependency(%q<hoe-git>.freeze, ["~> 1.6"])
    s.add_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
    s.add_dependency(%q<hoe-travis>.freeze, ["~> 1.2"])
    s.add_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
    s.add_dependency(%q<minitest-bonus-assertions>.freeze, ["~> 1.0"])
    s.add_dependency(%q<minitest-focus>.freeze, ["~> 1.1"])
    s.add_dependency(%q<minitest-moar>.freeze, ["~> 0.0"])
    s.add_dependency(%q<minitest-stub-const>.freeze, ["~> 0.4"])
    s.add_dependency(%q<rack-test>.freeze, ["~> 0.6"])
    s.add_dependency(%q<rake>.freeze, ["< 12", ">= 10.0"])
    s.add_dependency(%q<i18n-tasks>.freeze, ["~> 0.8"])
    s.add_dependency(%q<i18n-tasks-csv>.freeze, ["~> 1.0"])
    s.add_dependency(%q<rubocop>.freeze, ["~> 0.32"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.7"])
    s.add_dependency(%q<coveralls>.freeze, ["~> 0.8"])
    s.add_dependency(%q<hoe>.freeze, ["~> 3.15"])
  end
end
