require 'cog/config'
require 'cog/mixins/uses_templates'

module Cog
  
  class Tool

    include Mixins::UsesTemplates
    
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
    
    def initialize(name)
      @name = name.to_s.downcase
      @module_name = name.to_s.capitalize
      @author = '<Your name goes here>'
      @email = 'youremail@...'
      @description = 'A one-liner'
    end
    
    def generate!
      context = {
        :source_prefix => "#{Config.gem_dir}/templates/tool",
        :destination_prefix => name
        }
      stamp 'bin', "bin/#{name}", context
      stamp 'Gemfile', 'Gemfile', context
      stamp 'tool.rb', "lib/#{name}.rb", context
      stamp 'version.rb', "lib/#{name}/version.rb", context
      stamp 'tool.gemspec', "#{name}.gemspec", context
      stamp 'LICENSE', 'LICENSE', context
      stamp 'Rakefile', 'Rakefile', context
      stamp 'README.markdown', 'README.markdown', context
      touch_path name, "cog", "generators"
      touch_path name, "cog", "templates"
    end
  end

end