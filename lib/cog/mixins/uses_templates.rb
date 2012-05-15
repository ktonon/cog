require 'cog/config'
require 'erb'

module Cog
  module Mixins
    
    # Mixin for classes that can use templates to generate code
    module UsesTemplates
      
      # Get the template with the given name.
      #
      # === Parameters
      # * +path+ - a path to a template file which is relative to
      #   Config#template_dir and does not include the +.erb+ extension.
      #
      # === Options
      # * <tt>:absolute</tt> - set to +true+ to indicate that path is absolute
      #   and should not be prefixed. Default value is +false+.
      #
      # === Returns
      # An instance of ERB.
      def get_template(path, opt={})
        path += '.erb'
        path = File.join Config.for_project.template_dir, path unless opt[:absolute]
        raise MissingTemplate.new path unless File.exists? path
        ERB.new File.read(path)
      end
    
      # Stamp this object using the template at the given path.
      #
      # === Parameters
      # * +path+ - to the template which is relative to Config#template_dir and 
      #   does not include the +.erb+ extension.
      #
      # === Options
      # * <tt>:target</tt> - the destination path to the generated file which is
      #   relative to either Config#app_dir or Config#cog_dir, depending on the
      #   value of the <tt>:target_type</tt> option.
      # * <tt>:target_type</tt> - either <tt>:cog</tt> or <tt>:app</tt>.
      #   Determines what path to prefix to the <tt>:target</tt> option. The
      #   default value is <tt>:app</tt>
      # * <tt>:use_absolute_path</tt> - set to +true+ to indicate that path is
      #   absolute and should not be prefixed. Default value is +false+.
      # * <tt>:binding</tt> - specify an alternate binding to use when resolving
      #   the +ERB+ template. If none is provided +self.binding+ will be used.
      #
      # === Returns
      # +nil+ if generated to a file, otherwise returns the generated code as a
      # string.
      def stamp(path, opt={})
        t = get_template path, :absolute => opt[:use_absolute_path]
        b = opt[:binding] || binding
        target = opt[:target]
        if target.nil?
          t.result(b)
        else
          target_type = opt[:target_type] || :app
          target = case target_type.to_s
          when /cog/i
            File.join Config.for_project.cog_dir, target
          when /app/i
            File.join Config.for_project.app_dir, target
          end
          FileUtils.mkpath File.dirname(target) unless File.exists? target
          scratch = case target_type.to_s
          when /cog/i
            File.join Config.for_project.cog_dir, "#{opt[:target]}.scratch"
          when /app/i
            File.join Config.for_project.app_dir, "#{opt[:target]}.scratch"
          end
          File.open(scratch, 'w') {|file| file.write t.result(b)}
          unless same? target, scratch
            puts "Generated #{target}"
            FileUtils.mv scratch, target
          else
            FileUtils.rm scratch
          end
          nil
        end
      end
    
    private
      def same?(original, scratch) # :nodoc:
        if File.exists? original
          File.read(original) == File.read(scratch)
        else
          false
        end
      end
    end
    
  end
  
  module Errors
    # Indiciates an attempt to use a non-existant template.
    class MissingTemplate < Exception
      def message
        'could not find the template ' + super
      end
    end
  end
  
end
