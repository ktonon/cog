require 'cog/errors'

module Cog
  module Generator
    
    # Filters are methods which translate text into more text
    module Filters
      
      # @param text [String] some text which should be rendered as a comment
      # @return [String] a comment appropriate for the current language context
      def comment(text)
        Cog.active_language.comment text
      end

      # Call a filter by name
      # @param name [Symbol] the filter to call
      # @param text [String] the text to pass through the filter
      # @return [String] the filtered text
      def call_filter(name, text)
        gcontext[:filters] ||= %w(comment)
        name = name.to_s
        raise Errors::NoSuchFilter.new(name) unless gcontext[:filters].member? name
        method(name).call text
      end
      
    end
  end
end