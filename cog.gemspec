# Ensure we require the local version and not one we might have installed already
require File.join(File.dirname(__FILE__),'lib','cog/version.rb')
spec = Gem::Specification.new do |s| 
  s.name = 'cog'
  s.description = 'Command-line utility that makes it easy to organize a project which uses code generation'
  s.version = Cog::VERSION
  s.author = 'Kevin Tonon'
  s.licenses = ['MIT']
  s.email = 'kevin@betweenconcepts.com'
  s.homepage = 'https://github.com/ktonon/cog'
  s.platform = Gem::Platform::RUBY
  s.summary = 'This is a utility to help you write code generators.'
  s.files = %w(bin/cog BuiltIn.cogfile LICENSE) + Dir.glob('built_in/**/*') + Dir.glob('lib/**/*') + Dir.glob('yard-templates/**/*')
  s.require_paths << 'lib'
  s.has_rdoc = 'yard'
  s.bindir = 'bin'
  s.executables << 'cog'
  s.add_dependency('activesupport', '~> 4.1.0')
  s.add_dependency('gli', '~> 2.0')
  s.add_dependency('i18n', '~> 0.0')
  s.add_dependency('rainbow', ' ~> 2.0')
  s.add_development_dependency('rake', '~> 10.0')
  s.add_development_dependency('redcarpet', '~> 3.0')
  s.add_development_dependency('rspec', '~> 3.0')
  s.add_development_dependency('yard', '~> 0.0')
end
