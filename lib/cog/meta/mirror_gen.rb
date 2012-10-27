require 'cog/meta/gen_gen'

module Cog
  module Meta
    
    # Generates a Cog::Mixins::Mirror and associated templates.
    class MirrorGen
      
      # Create a mirror generator
      #
      # === Parameters
      # * +name+ - the name of the mirror. Will be forced to singular form.
      def initialize(name, opt={})
        @name = name.singularize
        @gg = GenGen.new
      end
      
      def filename
        @name.underscore
      end
      
      def classname
        @name.camelize
      end
      
      def abstract_classname
        "Cog#{@name.camelize}"
      end
      
      def stamp(opt={})
        opt[:binding] = binding
        @gg.stamp_generator 'mirror', filename, opt
        @gg.stamp_module 'mirror-abstract', "abstract_#{filename}", opt
        @gg.stamp_module 'mirror-impl', filename, opt
      end
    end
      
  end
end
