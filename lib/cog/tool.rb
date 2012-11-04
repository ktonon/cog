require 'cog/config'
require 'cog/generator'

module Cog
  
  # For more details on writing tools see https://github.com/ktonon/cog#tools
  class Tool

    # A list of available tools
    def self.list
      # TODO: use paths to instantiate a list of Tool objects
      paths = ENV['COG_TOOLS'] || []
    end
    
    # Generate a new tool with the given name
    def self.create(name)
      Object.new.instance_eval do
        class << self ; include Generator ; end
        @name = name.to_s.downcase
        @module_name = name.to_s.capitalize
        @author = '<Your name goes here>'
        @email = 'youremail@...'
        @description = 'A one-liner'
        @cog_version = Cog::VERSION
        stamp 'cog/tool/tool.rb', "#{@name}/lib/#{@name}.rb", :absolute_destination => true
        stamp 'cog/tool/version.rb', "#{@name}/lib/#{@name}/version.rb", :absolute_destination => true
        stamp 'cog/tool/generator.rb', "#{@name}/cog/templates/#{@name}/generator.rb.erb", :absolute_destination => true
        stamp 'cog/tool/Gemfile', "#{@name}/Gemfile", :absolute_destination => true
        stamp 'cog/tool/Rakefile', "#{@name}/Rakefile", :absolute_destination => true
        stamp 'cog/tool/tool.gemspec', "#{@name}/#{@name}.gemspec", :absolute_destination => true
        stamp 'cog/tool/API.rdoc', "#{@name}/API.rdoc", :absolute_destination => true
        stamp 'cog/tool/LICENSE', "#{@name}/LICENSE", :absolute_destination => true
        stamp 'cog/tool/README.markdown', "#{@name}/README.markdown", :absolute_destination => true
      end
    end
  end

end