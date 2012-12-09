require 'cog/errors'
require 'cog/languages/language'

module Cog
  
  # Submodules define helpers for the target languages supported by +cog+
  module Languages
    
    # @return [Hash] a mapping from file extensions to languages identifiers
    DEFAULT_LANGUAGE_EXTENSION_MAP = {
      :c => 'c',
      :cpp => 'c++',
      :cs => 'c#',
      :h => 'c',
      :hpp => 'c++',
      :java => 'java',
      :js => 'javascript',
      :pro => 'qt',
      :py => 'python',
      :rb => 'ruby',
    }

    # @return [Hash] a mapping from language aliases to language identifiers
    ALIAS = {
      'c++' => 'c_plus_plus',
      'c#' => 'c_sharp',
      'javascript' => 'java_script',
      'qt' => 'qt_project',
    }
    
    # @return [Hash] a mapping of language identifiers to lists of aliases
    REV_ALIAS = {}
    ALIAS.each_pair do |a, lang|
      REV_ALIAS[lang] ||= []
      REV_ALIAS[lang] << a
    end
    
    # @param lang_id [String] a langauge identifier
    # @return [Language] a language helper corresponding to the given identifier
    def self.get_language(lang_id)
      lang_id = Languages::ALIAS[lang_id] || lang_id
      require "cog/languages/#{lang_id.to_s.downcase}_language"
      Languages.instance_eval {const_get "#{lang_id.camelize}Language"}.new
    rescue LoadError
      raise Errors::NoSuchLanguage.new lang_id
    end
    
  end

end
