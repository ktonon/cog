module Cog
  module Languages
    module Mixins
      
      # Methods for defining single line comments that begin with a hash (<tt>#</tt>)
      module HashComments
        
        def comment_pattern(nested_pattern)
          /^\s*\#\s*#{nested_pattern}\s*$/i
        end

        def one_line_comment(text)
          "# #{text}"
        end
      
      end
    end
  end
end
