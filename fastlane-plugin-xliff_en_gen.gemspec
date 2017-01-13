# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/xliff_en_gen/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-xliff_en_gen'
  spec.version       = Fastlane::XliffEnGen::VERSION
  spec.author        = %q{alexander sun}
  spec.email         = %q{luc.alexander.sun@icloud.com}

  spec.summary       = %q{gen Localizable.strings file from xliff}
  spec.homepage      = "https://github.com/xiangyu-sun/fastlane-plugin-xliff_en_gen"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency 'nokogiri', '~> 1.7'

  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'fastlane', '>= 2.5.0'
end
