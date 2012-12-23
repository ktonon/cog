module Cog
  module Generator
    
    # Methods to help with generating language constructs
    module LanguageMethods
      
      autoload :Scope, 'cog/generator/language_methods/scope'
      
      # @return [String] a warning comment not to edit the generated file
      def warning
        stamp 'warning', :filter => 'comment'
      end

      # Begin a scope, pushing it onto the scope stack
      # @param scope [Scope] the scope to begin
      # @return [String] the scope begin statement
      def scope_begin(scope)
        gcontext[:scopes] << scope
        Cog.active_language.method("#{scope.type}_begin").call(scope.name)
      end
      
      # End the scope, popping it off the scope stack
      # @option opt [Boolean] :safe_pop (false) do not throw an exception if the stack is empty, instead, return +nil+
      # @return [String, nil] the scope end statement, or +nil+ if <tt>:safe_pop</tt> and the stack is empty
      def scope_end(opt={})
        if gcontext[:scopes].empty?
          raise Errors::ScopeStackUnderflow.new(self) unless opt[:safe_pop]
          return nil
        end
        scope = gcontext[:scopes].pop
        Cog.active_language.method("#{scope.type}_end").call(scope.name)
      end
      
      # End all scope currently on the stack
      # @return [String]
      def end_all_scopes
        lines = []
        while line = scope_end(:safe_pop => true)
          lines << line
        end
        lines.join "\n"
      end

      # @param name [String] name of the scope to use
      # @return [String] a using statement for the named scope
      def use_named_scope(name)
        Cog.active_language.use_named_scope(name)
      end

      # @param name [String] name of the scope
      # @return [String] a scope begin statement
      def named_scope_begin(name = nil)
        scope_begin Scope.new(:named_scope, name)
      end

      alias :named_scope_end :scope_end

      # @param name [String] name of the module
      # @return [String] an include guard statement for the active language
      def include_guard_begin(name = nil)
        scope_begin Scope.new(:include_guard, name)
      end

      alias :include_guard_end :scope_end
      
    end
  end
end