require 'cog/config'

module Cog
  module Directives
    
    # Describes the environment of a cog directive including the file in which it was found, the line number, the language, an more.
    class Context
      
      # @return [Fixnum] line number at which the directive was found
      attr_accessor :lineno

      # @param path [String] path to the file in which the cog directive was found
      def initialize(path)
        @options = {}
        @path = path
      end
            
      # @param key [String] named arguments used with the directive
      # @return [String] the value for the given key
      def [](key)
        @options[key]
      end
      
      # @return [Array<String>] arguments passed to the directive
      def args
        @args
      end
      
      # @return [String] for block directives, the body of text which occurs between the curly braces.
      # @example
      #   // cog: snippet(my-snip) {
      #   body
      #   // cog: }
      def body
        @body
      end
      
      # @return [String] the filename extension
      def extension
        @ext ||= File.extname(filename).slice(1..-1)
      end

      # @return [String] basename of the file in which the cog directive was found
      def filename
        @filename ||= File.basename @path
      end

      # @return [Languages::Language] the language of the file
      def language
        @lang ||= Config.instance.language_for_extension extension
      end
      
      # @return [Boolean] was the once switch used?
      def once?
        @once
      end

      # @api developer
      # @param value [String, nil] set the body to this value
      def body=(value)
        @body = value
      end
      
      # @api developer
      # @param value [Boolean] was the once switch used?
      def once=(value)
        @once = !!value
      end
      
      # @api developer
      # @param value [Array<String>] arguments used with the directive
      def args=(value)
        @args = value
      end
      
    end
    
  end
end
