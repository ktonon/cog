module Cog
  
  module Errors
    
    # Root type for all cog errors
    class CogError < Exception
      def initialize(details={})
        @details = if details.is_a? Hash
          details.to_a.collect do |key, value|
            "#{key} => #{value.inspect}"
          end.sort
        else
          [details]
        end
      end

      def message
        w = custom_message || self.class.name.underscore.split('/').last.gsub('_', ' ')
        w += " (#{@details.join ', '})" unless @details.empty?
        w
      end
    end
    
    # Define a +cog+ error class
    # @api developer
    # @param class_name [String] name of the error class
    def self.define_error(class_name, &block)
      cls = Class.new CogError
      Errors.instance_eval { const_set class_name, cls }
      cls.instance_eval do
        define_method :custom_message do
          block.call if block
        end
      end
    end

    define_error :ActionRequiresProjectGeneratorPath
    define_error :ActionRequiresProjectTemplatePath
    define_error :ActionRequiresProjectPluginPath
    
    define_error :DuplicateGenerator
    define_error :DuplicatePlugin
    define_error :DuplicateKeep

    define_error :InvalidPluginConfiguration do
      "invalid directory structure for a cog plugin"
    end
    
    define_error :UnrecognizedKeepHook do
      "looks like that hook is longer being generated"
    end
    
    define_error :NoSuchFilter
    define_error :NoSuchGenerator
    define_error :NoSuchLanguage
    define_error :NoSuchTemplate
    define_error :NoSuchPlugin
    
    define_error :PluginPathIsNotADirectory
    
    define_error :ScopeStackUnderflow do
      "scope stack underflow: this can happen if you have too many *_end calls in a template"
    end
    
    define_error :SnippetExpansionUnterminated do
      "a embed expansion in the given file is missing the 'cog: }' terminator"
    end
    
    define_error :PluginMissingDefinition do
      "the plugin was not fully defined"
    end
  end
end
