require 'erb'

module Cog

  # Mixin for classes that can use templates to generate code
  module HasTemplate
    
    # Get the template with the given name.
    #
    # === Parameters
    # * +path+ - a path to a template file which is relative to
    #   Cogfile#template_dir and does not include the +.erb+ extension.
    #
    # === Returns
    # An instance of ERB.
    def get_template(path)
      path = File.join Cogfile.instance.template_dir, "#{path}.erb"
      unless File.exists? path
        raise MissingTemplate.new path
      end
    end
    
    # Stamp this object using the template at the given path.
    #
    # === Parameters
    # * +path+ - the path to the template to use which is relative to
    #   Config#template_dir and does not include the +.erb+ extension.
    # * +dest+ - the destination path to the generated file which is relative
    #   to Config#code_dir. If this is not provided, then the generated code
    #   will be returned as a string.
    #
    # === Returns
    # +nil+ if generated to a file, otherwise returns the generated code as a
    # string.
    def stamp(path, dest=nil)
    end
  end

  class MissingTemplate < Exception
    def message
      'could not find the template ' + super
    end
  end
end
