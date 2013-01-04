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

    define_error :ActionRequiresProjectGeneratorPath, 'action'
    define_error :ActionRequiresProjectTemplatePath, 'action'
    define_error :ActionRequiresProjectPluginPath, 'action'
    
    define_error :DuplicateGenerator, 'generator'
    define_error :DuplicatePlugin, 'plugin'
    define_error :DuplicateKeep, 'keep'

    define_error :InvalidPluginConfiguration, 'path to cog_plugin.rb file' do
      "invalid directory structure for a cog plugin"
    end
    
    define_error :NoSuchFilter, 'filter'
    define_error :NoSuchGenerator, 'generator'
    define_error :NoSuchLanguage, 'language'
    define_error :NoSuchTemplate, 'template'
    define_error :NoSuchPlugin, 'plugin'
    
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
