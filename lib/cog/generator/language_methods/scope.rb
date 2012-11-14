module Cog
  module Generator
    module LanguageMethods
      
      # Defines a program scope
      class Scope
        
        # @return [Symbol] type of the scope. For example, <tt>:include_guard</tt>
        attr_reader :type
        
        # @return [String, nil] name of the scope
        attr_reader :name
        
        # @param type [String] type of the scope
        # @param name [String] name of the scope
        def initialize(type, name=nil)
          @type = type.to_sym
          @name = name
        end
      end
      
    end
  end
end