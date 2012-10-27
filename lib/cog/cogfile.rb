module Cog

  # In your project's +Cogfile+, +self+ has been set to an instance of this class.
  #
  # ==== Example +Cogfile+
  #   cog_dir 'cog'
  #   app_dir 'src'
  #   language 'c++'
  #
  # Typing `cog init` will create a +Cogfile+ in the present working directory.
  #
  # +Cogfile+ files are used to configure an instance of Config.
  class Cogfile
    
    def initialize(config) # :nodoc:
      @config = config
    end
    
    # Interpret the Cogfile and initialize @config
    def interpret # :nodoc:
      eval File.read(@config.cogfile_path), binding
    rescue Exception => e
      raise CogfileError.new(e.to_s)
    end
    
    # Define the directory in which to place Ruby generators and +ERB+ templates.
    # ==== Arguments
    # * +path+ - A file system path
    # * +absolute+ - If false, the path is relative to the directory containing the +Cogfile+
    def cog_dir(path, absolute=false)
      @config.instance_eval do
        @cog_dir = absolute ? path : File.join(project_root, path)
        @generator_dir = File.join @cog_dir, 'generators'
        @template_dir = File.join @cog_dir, 'templates'
      end
    end

    # Define the directory in which to place generated application source code.
    # ==== Arguments
    # * +path+ - A file system path
    # * +absolute+ - If false, the path is relative to the directory containing the +Cogfile+
    def app_dir(path, absolute=false)
      @config.instance_eval do
        @app_dir = absolute ? path : File.join(project_root, path)
      end
    end

    # Define the default language in which to generated application source code.
    # ==== Arguments
    # * +lang+ - A code for the language. Acceptable values are <tt>c++</tt>.
    def language(lang)
      @config.instance_eval do
        @language = lang
      end
    end
  end

  # For wrapping errors which occur during the processing of a +Cogfile+.
  class CogfileError < StandardError
    def message
      "in Cogfile, " + super
    end
  end

end
