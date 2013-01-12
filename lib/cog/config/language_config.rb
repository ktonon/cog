module Cog
  module Config
    
    # {Config} methods related to languages
    module LanguageConfig
      
      # @return [Language] language which is active in the current context
      def active_language
        @active_languages.last
      end

      # Activate a given language within the scope of the provided block.
      # Either provide <tt>key</tt>, <tt>:ext</tt>, or <tt>:filename</tt> but not more than one. If the extension does not match any of the supported languages, the {#active_language} will not change, but the block will still be called.
      # @param key [:String] the lanuage identifier. Type <tt>cog language list</tt> to see the possible values
      # @option opt [:String] :ext (nil) a file extension which will map to a language identifier. Type <tt>cog language map</tt> to see mapped extensions
      # @option opt [:String] :filename (nil) a filename or path to file which will map to a language identifier
      # @yield within this block the {#active_language} will be set to the desired value
      # @return [Object] the value returned by the block
      def activate_language(key, opt={}, &block)
        opt, key = key, nil if key.is_a? Hash
        key = if opt[:ext]
          ext = opt[:ext].to_s.downcase
          ext = ext.slice(1..-1) if ext.start_with?('.')
          @language_extension_map[ext] unless ext.empty?
        elsif opt[:filename]
          ext = File.extname(opt[:filename]).slice(1..-1)
          @language_extension_map[ext] unless ext.nil? || ext.empty?
        else
          key
        end
        if key
          @active_languages << @language[key]
          if block
            r = block.call
            @active_languages.pop
            r
          end
        else
          block.call
        end
      end

      # @return [Array<String>] list of file extensions for supported languages
      def language_extensions
        @language_extension_map.keys
      end

      # @param key [String] the language key
      # @return [Language] the language for the given key
      def language(key)
        @language[key]
      end
      
      # @param path [String] the file system extension, or full path to a file
      # @return [Language, nil] the language for the given extension
      def language_for(path)
        ext = File.extname(path.to_s)
        ext = path.to_s if ext.empty?
        ext = ext.downcase
        ext = ext.slice(1..-1) if ext.start_with? '.'
        key = @language_extension_map[ext]
        @language[key] if key
      end

      # @return [Array<Language>] current configuration of supported languages
      def language_summary
        @language.values.sort
      end
    
    end
  end
end
