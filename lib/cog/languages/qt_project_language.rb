require 'cog/languages/language'
require 'cog/languages/mixins/hash_comments'

module Cog
  module Languages
    
    class QtProjectLanguage < Language
      include Mixins::HashComments

      def module_extensions
        [:pro, :pri]
      end
      
    end
  end
end
