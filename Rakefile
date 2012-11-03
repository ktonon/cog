require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
require 'rspec/core/rake_task'

Rake::RDocTask.new do |rd|
  rd.main = "API.rdoc"
  rd.rdoc_files.include("API.rdoc", "lib/**/*.rb")
  rd.title = 'cog API Docs'
end

spec = eval(File.read('cog.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end

RSpec::Core::RakeTask.new :spec do |t|
	t.pattern = "./spec/**/*_spec.rb"
end

task :default => :spec
