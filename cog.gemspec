# Ensure we require the local version and not one we might have installed already
require File.join(File.dirname(__FILE__),'lib','cog/version.rb')
spec = Gem::Specification.new do |s| 
  s.name = 'cog'
  s.version = Cog::VERSION
  s.author = 'Kevin Tonon'
  s.email = 'kevin@betweenconcepts.com'
  s.homepage = 'https://github.com/ktonon/cog'
  s.platform = Gem::Platform::RUBY
  s.summary = 'This is a utility to help you write code generators.'
  s.files = %w(bin/cog Default.cogfile LICENSE) + Dir.glob('templates/**/*') + Dir.glob('lib/**/*.rb')
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['API.rdoc']
  s.rdoc_options << '--title' << 'cog' << '--main' << 'cog.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'cog'
  s.add_dependency('gli')
  s.add_dependency('rainbow')
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
end
