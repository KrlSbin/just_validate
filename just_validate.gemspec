# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'just_validate'
  s.version     = '0.0.3'
  s.date        = '2024-10-11'
  s.summary     = 'Just validate'
  s.description = 'A simple validation module'
  s.authors     = ['Kyrylo Skriabin']
  s.email       = 'ckp9l6ih@gmail.com'
  s.files       = ['lib/just_validate.rb']
  s.homepage    = 'https://github.com/KrlSbin/just_validate'
  s.license     = 'MIT'
  s.add_development_dependency 'rspec', ['>= 3.13.0']
  s.required_ruby_version = '>= 2.5.0'
end
