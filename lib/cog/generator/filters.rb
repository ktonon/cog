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

      # @api developer
      # Adds a call_filter method which throws NoSuchFilter if
      # the filter is invalid
      def self.included(other)
        valid_filters = Filters.instance_eval {instance_methods}
        other.instance_eval do
          define_method "call_filter" do |name, text|
            raise Errors::NoSuchFilter.new(name) unless valid_filters.member?(name.to_s)
            method(name).call text
          end
        end
      end

    end
  end
end