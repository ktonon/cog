require 'cog/config/lang_info'

module Cog
  module Config
    
    # {Config} methods related to languages
    module LanguageMethods
      
      # @return [Languages::Lanugage] target language which should be used when creating generators, and no language is explicitly specified
      attr_accessor :target_language
      
      # @return [Languages::Language] language which is active in the current context
      def active_language
        @active_languages.last
      end

      # Activate a given language within the scope of the provided block.
      # Either provide <tt>:id</tt> or <tt>:ext</tt> but not both. If the extension does not match any of the supported languages, the {#active_language} will not change, but the block will still be called.
      # @option opt [:String] :id (nil) the lanuage identifier. Type <tt>cog language list</tt> to see the possible values
      # @option opt [:String] :ext (nil) a file extension which will map to a language identifier. Type <tt>cog language map</tt> to see mapped extensions
      # @yield within this block the {#active_language} will be set to the desired value
      # @return [Object] the value returned by the block
      def activate_language(opt={}, &block)
        throw :ActivateLanguageRequiresABlock if block.nil?
        lang_id = if opt[:ext]
          ext = opt[:ext].to_s
          ext = ext.slice(1..-1) if ext.start_with?('.')
          @language_extension_map[ext.downcase.to_sym] unless ext.empty?
        else
          opt[:id]
        end
        if lang_id
          @active_languages << Languages.get_language(lang_id)
          r = block.call
          @active_languages.pop
          r
        else
          block.call
        end
      end

      # @return [Array<String>] list of file extensions for supported languages
      def language_extensions
        @language_extension_map.keys
      end

      # @param path [String] the file system extension, or full path to a file
      # @return [Languages::Language, nil] the language for the given extension
      def language_for(path)
        ext = File.extname(path.to_s)
        ext = path.to_s if ext.empty?
        ext = ext.downcase
        ext = ext.slice(1..-1) if ext.start_with? '.'
        lang_id = @language_extension_map[ext.to_sym]
        Languages.get_language lang_id unless lang_id.nil?
      end

      # @return [Array<LangInfo>] current configuration of supported languages
      def language_summary
        summary = {}
        @language_extension_map.each_pair do |ext, lang_id|
          lang_id = Languages::ALIAS[lang_id] || lang_id
          summary[lang_id] ||= LangInfo.new(lang_id, Languages::REV_ALIAS[lang_id] || [])
          summary[lang_id].extensions << ext
        end
        summary.values.sort
      end
    
    end
  end
end
