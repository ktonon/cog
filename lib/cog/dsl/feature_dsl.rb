module Cog
  module DSL
    
    # DSL for defining cog features
    class FeatureDSL
      
      # @api developer
      # @return [Cog::Seed] the seed which is defined by this DSL object
      attr_reader :feature
      
      # @api developer
      def initialize(seed, name, opt={})
        @feature = Seed::Feature.new seed, name
      end

      # Describe what this method does in one line
      # @param value [String] a short description
      # @return [nil]
      def desc(value)
        feature_eval { @desc = value }
        nil
      end
      
      # Declare this method abstract
      # @return [nil]
      def abstract
        feature_eval { @abstract = true }
        nil
      end
      
      # Add a parameter to the feature
      # @param type [Symbol] the type of the parameter
      # @param name [String] name of the parameter
      # @option opt [String] :desc (nil) optional description which will be used in documentation
      # @option opt [Seed] :scope (nil) optional scope to use when rendering the variable in a qualified way
      # @return [nil]
      def param(type, name, opt={})
        v = Seed::Var.new type, name, opt
        feature_eval { @params << v }
        nil
      end
      
      # Define the return type for the method.
      # Will be `:void` if this method is never called.
      # @param type [Symbol] a type
      # @return [nil]
      def return(type)
        feature_eval { @return_type = type }
        nil
      end
      
      private
      
      def feature_eval(&block)
        @feature.instance_eval &block
      end
    end
  end
end
