module Cog
  module Config
    
    # Describes configuration of a supported language
    class LangInfo
      # @return [String] a language identifier
      attr_reader :lang_id
      
      # @return [Array<String>] a list of aliases
      attr_reader :aliases
      
      # @return [Array<Symbol>] a list of extension which currently map to this language
      attr_reader :extensions
      
      # @return [String] readable name of the language
      attr_reader :name
      
      # @api developer
      def initialize(lang_id, aliases)
        @lang_id = lang_id
        @aliases = aliases.dup
        @name = @aliases.empty? ? @lang_id : @aliases.join(', ')
        @extensions = []
      end

      # @param w [FixNum] width of the first column
      # @return [String] one line summary in two columns
      def to_s(w=nil)
        w ||= name.length
        "#{name.ljust w} -> #{@extensions.collect {|x| x.to_s}.sort.join ', '}"
      end
      
      # Sort by name
      def <=>(other)
        name <=> other.name
      end
    end
    
  end
end