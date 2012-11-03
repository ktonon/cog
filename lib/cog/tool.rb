require 'cog/config'
require 'cog/generator'

module Cog
  
  # For more details on writing tools see https://github.com/ktonon/cog#tools
  class Tool

    # A list of available tools
    def self.available
      # TODO: use paths to instantiate a list of Tool objects
      paths = ENV['COG_TOOLS'] || []
    end
    
    # Generate a new tool with the given name
    def self.generate_tool(name)
      Object.new.instance_eval do
        class << self ; include Generator ; end
        @name = name.to_s.downcase
        @module_name = name.to_s.capitalize
        @author = '<Your name goes here>'
        @email = 'youremail@...'
        @description = 'A one-liner'
        @cog_version = Cog::VERSION
        stamp 'cog/tool/tool.rb', "#{@name}/lib/#{@name}.rb"
        stamp 'cog/tool/version.rb', "#{@name}/lib/#{@name}/version.rb"
        stamp 'cog/tool/generator.rb', "#{@name}/cog/templates/#{@name}/generator.rb.erb"
        stamp 'cog/tool/Gemfile', "#{@name}/Gemfile"
        stamp 'cog/tool/Rakefile', "#{@name}/Rakefile"
        stamp 'cog/tool/tool.gemspec', "#{@name}/#{@name}.gemspec"
        stamp 'cog/tool/API.rdoc', "#{@name}/API.rdoc"
        stamp 'cog/tool/LICENSE', "#{@name}/LICENSE"
        stamp 'cog/tool/README.markdown', "#{@name}/README.markdown"
      end
    end
  end

end