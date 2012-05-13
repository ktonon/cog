require 'cog/cogfile'
require 'erb'

module Cog
  module Mixins
    
    # Mixin for classes that can use templates to generate code
    module UsesTemplates
    
      # Use an alternate Cogfile
      def using_cogfile(cogfile)
        @cogfile = cogfile
      end
      
      # Get the template with the given name.
      #
      # === Parameters
      # * +path+ - a path to a template file which is relative to
      #   Cogfile#template_dir and does not include the +.erb+ extension.
      #
      # === Returns
      # An instance of ERB.
      def get_template(path)
        @cogfile ||= Cogfile.for_project
        path = File.join @cogfile.template_dir, "#{path}.erb"
        unless File.exists? path
          raise MissingTemplate.new path
        end
        ERB.new File.read(path)
      end
    
      # Stamp this object using the template at the given path.
      #
      # === Parameters
      # * +path+ - the path to the template to use which is relative to
      #   Cogfile#template_dir and does not include the +.erb+ extension.
      # * +dest+ - the destination path to the generated file which is relative
      #   to Cogfile#code_dir. If this is not provided, then the generated code
      #   will be returned as a string.
      #
      # === Context
      # All keys are added as instance variables to the context that is passed
      # into the template.
      #
      # === Returns
      # +nil+ if generated to a file, otherwise returns the generated code as a
      # string.
      def stamp(path, dest=nil, context={})
        t = get_template path
        context = TemplateContext.new self, context
        b = context.instance_eval {binding}
        if dest.nil?
          t.result(b)
        else
          dest = File.join @cogfile.code_dir, dest
          FileUtils.mkpath File.dirname(dest) unless File.exists? dest
          scratch = "#{path}.scratch"
          File.open(scratch, 'w') {|file| file.write t.result(b)}
          unless same? dest, scratch
            puts "Generated #{dest}"
            FileUtils.mv scratch, dest
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
      
      class TemplateContext # :nodoc:
        def initialize(obj, context={})
          @obj = obj
          context.each do |key, value|
            instance_variable_set "@#{key}", value
          end
        end
        
        def method_missing(meth, *args, &block)
          if @obj.respond_to? meth
            @obj.method(meth).call *args, &block
          else
            super
          end
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
