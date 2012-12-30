require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rspec/core/rake_task'
require 'yard'

YARD::Rake::YardocTask.new do |t|
  t.files = ["lib/**/*.rb", "README.md", "CHANGELOG.md"]
  t.options = [
    '--query', '@api.text != "unstable" && @api.text != "developer"', 
    '-p', 'yard-templates', '-t', 'default']
end

spec = eval(File.read('cog.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end

RSpec::Core::RakeTask.new :spec do |t|
	t.pattern = "./spec/**/*_spec.rb"
end

task :default => :spec
