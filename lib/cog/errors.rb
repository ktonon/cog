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
    
    define_error :CouldNotLoadTool, 'tool'
    
    define_error :DestinationAlreadyExists, 'path' do
      "a file or directory at the given path already exists, cannot create anything there"
    end

    define_error :DuplicateGenerator, 'generator'
    
    define_error :DuplicateTemplate, 'template'

    define_error :DuplicateTool, 'tool'

    define_error :InvalidToolConfiguration, 'path to cog_tool.rb file' do
      "invalid directory structure for a cog tool"
    end
    
    define_error :NoSuchFilter, 'filter'
    
    define_error :NoSuchGenerator, 'generator'
    
    define_error :NoSuchLanguage, 'language'

    define_error :NoSuchTemplate, 'template'

    define_error :NoSuchTool, 'tool' do
      "no such tool, make sure it appears in the COG_TOOLS environment variable"
    end
    
    define_error :ScopeStackUnderflow, 'caller' do
      "scope stack underflow: this can happen if you have too many *_end calls in a template"
    end
    
  end
end
