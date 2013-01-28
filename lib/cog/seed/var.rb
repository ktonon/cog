module Cog
  class Seed
    
    # Template for a variable in a target language
    class Var
      
      include Generator
      
      # @return [String] name of the variable
      attr_reader :name
      
      attr_reader :desc
      
      attr_reader :type
      
      attr_reader :scope
      
      # @api developer
      def initialize(type, name, opt={})
        @type = type
        @name = name.to_s.to_ident
        @desc = opt[:desc]
        @scope = opt[:scope]
      end

      def qualify?
        @qualify
      end

      def stamp_decl(qualify = false)
        l = Cog.active_language
        @qualify = qualify && @scope
        stamp "cog/#{l.key}/var_decl.#{l.seed_extension}"
      end
      
      # Sort by name
      def <=>(other)
        @name <=> other
      end

    end
  end
end
