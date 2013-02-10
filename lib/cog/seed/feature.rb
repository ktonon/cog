module Cog
  class Seed
    
    # Template for a method in a target language
    class Feature
      
      include Generator
      
      # @api developer
      # @return [Seed] seed to which this feature belongs
      attr_reader :seed
      
      # @return [Symbol] access modifier. One of `:public`, `:protected`, or `:private`
      attr_reader :access
      
      # @return [String] name of the method
      attr_reader :name
      
      # @return [Array<Var>] list of parameters
      attr_reader :params
      
      # @return [Symbol] the return type of the feature
      attr_reader :return_type
      
      # @api developer
      # @param seed [Seed] seed to which this feature belongs
      # @param name [String] name of the feature
      # @option opt [Symbol] :access (:private) one of `:public`, `:protected`, or `private`
      # @option opt [Boolean] :abstract (false) is this an abstract feature? If so, no implementation will be generated. Note that all abstract features are virtual
      # @option opt [Boolean] :virtual (false) is this a virtual feature? Virtual features can be replaced in subclasses
      def initialize(seed, name, opt={})
        @seed = seed
        @name = name.to_s.to_ident
        @access = (opt[:access] || :private).to_sym
        @abstract = !!opt[:abstract]
        @virtual = !!opt[:virtual]
        @params = [] # [Var]
        @return_type = :void
      end

      # @return [Boolean] is this an abstract method?
      def abstract?
        @abstract
      end
      
      # @return [Boolean] is this a virtual method?
      def virtual?
        @abstract || @virtual
      end
      
      # @return [Boolean] does this feature return a value?
      def returns_a_value?
        @return_type != :void
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
