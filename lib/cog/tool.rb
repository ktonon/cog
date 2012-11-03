require 'cog/config'
require 'cog/mixins/uses_templates'

module Cog
  
  class Tool

    # Lower case command-line version of the name
    attr_reader :name
    
    # Capitalized module name
    attr_reader :module_name

    # Name of the person who will be given copyright for the generated code
    attr_reader :author
    
    # Email address of the author
    attr_reader :email
    
    # A one-line description of the tool
    attr_reader :description
    
    # A list of available tools
    def self.available
      paths = ENV['COG_TOOLS'] || []
      
    end
    
    def self.generate_tool(name)
      Object.new.instance_eval do
        class << self ; include Mixins::UsesTemplates ; end
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
        stamp 'cog/tool/LICENSE', "#{@name}/LICENSE"
        stamp 'cog/tool/README.markdown', "#{@name}/README.markdown"
      end
    end
  end

end