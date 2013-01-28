module Cog
  class Seed
    
    # Template for a method in a target language
    class Feature
      
      include Generator
      
      attr_reader :seed
      
      # @return [String] name of the method
      attr_reader :name
      
      attr_reader :params
      
      attr_reader :return_type
      
      # @api developer
      # @param name [String] name of the method
      def initialize(seed, name, opt={})
        @seed = seed
        @name = name.to_s.to_ident
        @abstract = false
        @params = [] # [Var]
        @return_type = :void
      end

      # @return [Boolean] is this an abstract method?
      def abstract?
        @abstract
      end
      
      def desc
        @desc || 'Undocumented'
      end
      
      def keep_name
        "#{@seed.name}_#{@name}"
      end
            
      def stamp_method
        l = Cog.active_language
        ext = @seed.in_header? ? l.seed_header : l.seed_extension
        stamp "cog/#{l.key}/feature.#{ext}"
      end
      
      # Sort by name
      def <=>(other)
        @name <=> other.name
      end

    end
  end
end
