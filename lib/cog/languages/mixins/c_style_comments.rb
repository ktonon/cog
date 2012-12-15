module Cog
  module Languages
    module Mixins
      
      # Methods for defining single and multiline c-style comments
      module CStyleComments
        
        def comment_pattern(nested_pattern)
          /^\s*(?:\/\/|\/\*)\s*#{nested_pattern}\s*(?:\*\/)?\s*$/i
        end

        def one_line_comment(text)
          "// #{text}"
        end
      
        def multi_line_comment(text)
          "/*\n#{text}\n */"
        end
        
      end
    end
  end
end
