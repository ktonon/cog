# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','stamp_version.rb'])
spec = Gem::Specification.new do |s| 
  s.name = 'stamp'
  s.version = Stamp::VERSION
  s.author = 'Kevin Tonon'
  s.email = 'kevin@betweenconcepts.com'
  s.homepage = 'https://github.com/ktonon/stamp'
  s.platform = Gem::Platform::RUBY
  s.summary = 'This is a utility to help you write code generators.'
  s.files = %w(
bin/stamp
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['stamp.rdoc']
  s.rdoc_options << '--title' << 'stamp' << '--main' << 'stamp.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'stamp'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
end
