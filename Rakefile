require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rspec/core/rake_task'

Rake::RDocTask.new do |rd|
  rd.main = "stamp.rdoc"
  rd.rdoc_files.include("stamp.rdoc","lib/**/*.rb","bin/**/*")
  rd.title = 'Your application title'
end

spec = eval(File.read('stamp.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end

RSpec::Core::RakeTask.new :spec do |t|
	t.pattern = "./spec/**/*_spec.rb"
end

task :default => :spec
