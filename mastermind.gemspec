# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'Mastermind'
  s.version     = '1.2.0'
  s.licenses    = ['MIT']
  s.summary     = 'A gem to play `Mastermind`!'
  s.description = 'Play the class game `Mastermind` in your Terminal! Includes a solver!'
  s.authors     = ['Drew Spelman']
  s.email       = 'drewspelman@gmail.com'
  s.files       = Dir['{bin,lib,spec,helper}/**/*'] + %w[
    LICENSE README.md
  ]
  s.bindir      = 'bin'
  s.executables = ['Mastermind']
  s.homepage    = 'https://www.thisfoxcodes.com'
  s.metadata    = { 'source_code_uri' => 'https://github.com/dmspelma/mastermind',
                    'rubygems_mfa_required' => 'true' }
  s.required_ruby_version = '>=3.0'
end
