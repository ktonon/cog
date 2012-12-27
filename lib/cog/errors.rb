module Cog
  
  module Errors
    
    # Root type for all cog errors
    class CogError < Exception
    end
    
    # Define a +cog+ error class
    # @api developer
    #
    # @param class_name [String] name of the error class
    # @param arg [String] name of the argument to the constructor, will appear in error messages
    # @yield +self+ will be set to an instance of the error class and <tt>@msg</tt> will contain 
    def self.define_error(class_name, arg, &block)
      cls = Class.new CogError
      Errors.instance_eval { const_set class_name, cls }
      cls.instance_eval do
        define_method(:initialize) {|value| @value = value}
        define_method :message do
          msg = if block.nil?
            class_name.to_s.underscore.gsub '_', ' '
          else
            instance_eval &block
          end
          "#{msg} (#{arg} => #{@value})"
        end
      end
    end

    define_error :ActionRequiresProject, 'action' do
      "the action requires a project, but no Cogfile was found"
    end
    
    define_error :CouldNotLoadPlugin, 'plugin'
    
    define_error :DestinationAlreadyExists, 'path' do
      "a file or directory at the given path already exists, cannot create anything there"
    end

    define_error :DuplicateGenerator, 'generator'
    
    define_error :DuplicatePlugin, 'plugin'

    define_error :InvalidPluginConfiguration, 'path to cog_plugin.rb file' do
      "invalid directory structure for a cog plugin"
    end
    
    define_error :NoSuchFilter, 'filter'
    
    define_error :NoSuchGenerator, 'generator'
    
    define_error :NoSuchLanguage, 'language'

    define_error :NoSuchTemplate, 'template'

    define_error :NoSuchPlugin, 'plugin' do
      "no such plugin, make sure it appears in the COG_TOOLS environment variable"
    end
    
    define_error :NotAPluginCogfile, 'cogfile_path'
    
    define_error :PluginPathDoesNotExist, 'plugin_path'

    define_error :PluginPathIsNotADirectory, 'plugin_path'
    
    define_error :ScopeStackUnderflow, 'caller' do
      "scope stack underflow: this can happen if you have too many *_end calls in a template"
    end
    
    define_error :SnippetExpansionUnterminated, 'location' do
      "a embed expansion in the given file is missing the 'cog: }' terminator"
    end
    
    define_error :PluginMissingDefinition, 'missing' do
      "the plugin was not fully defined"
    end
  end
end
