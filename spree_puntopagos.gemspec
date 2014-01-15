# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'spree_puntopagos/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_puntopagos'
  s.version     = SpreePuntopagos::VERSION
  s.summary     = 'Plugs Puntopagos Payment Gateway into Spree Stores'
  s.description = 'Plugs Puntopagos Payment Gateway into Spree Stores'
  s.required_ruby_version = '>= 1.9.3'

  s.author      = 'Marcelo Espina'
  s.email       = ['mespina.icc@gmail.com', 'mespina@acid.cl']
  # s.homepage  = 'http://www.spreecommerce.com'

  s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.1.3'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.2'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'

  s.add_development_dependency 'puntopagos'
  s.add_runtime_dependency 'puntopagos'
end
