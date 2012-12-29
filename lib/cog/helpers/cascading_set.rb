module Cog
  module Helpers
    
    # @api developer
    class SourceInfo
      attr_reader :name
      attr_accessor :path
      
      def initialize(name)
        @info = []
        @types = []
        @name = name
      end
      
      def add_source(source, type=nil)
        type ||= source
        @info << source
        @types << type
      end
      
      def style(text, type)
        case type
        when :built_in
          text.color :cyan
        when :gem
          text.color :blue
        when :user
          text.color :green
        when :plugin
          text.color :yellow
        when :project
          text.color(:white).bright
        else
          text
        end
      end
      
      def override_s(width=nil)
        colorless = "[#{@info.join ' < '}]"
        if width
          x = @info.zip(@types).collect {|source, type| style source, type}
          "[#{x.join ' < '}]" + " " * (width - colorless.length)
        else
          colorless
        end
      end
      
      def <=>(other)
        (@path || @name) <=> (other.path || other.name)
      end
      
      def to_s(override_column_width)
        "#{override_s override_column_width} #{style @path || @name, @types.last}"
      end
    end
    
    # @api developer
    class CascadingSet
      def initialize
        @info = {}
      end

      # Look for sources in each of the given paths
      # @param paths [Array<String>] a list of file system paths containing sources
      # @option opt [String] :ext File extension of sources to glob for in each path
      # @return [Array<String>] formatted listing of the sources
      def self.process_paths(paths, opt={})
        cs = Helpers::CascadingSet.new
        paths.each_with_cog_source do |source, type, path|
          opt[:source] = source
          opt[:type] = type
          opt[:root_dir] = path
          cs.add_sources opt
        end
        cs.to_a
      end
      
      # @option opt [String] :source (nil) the name of the source
      # @option opt [Symbol] :type (nil) must be one of <tt>:built_in</tt>, <tt>:user</tt>, <tt>:plugin</tt>, or <tt>:project</tt>
      # @option opt [String] :root_dir (nil) directory in which to look for sources
      def add_sources(opt={})
        Dir.glob("#{opt[:root_dir]}/**/*.#{opt[:ext]}") do |path|
          name = path.relative_to(opt[:root_dir]).slice(0..-(2 + opt[:ext].length))
          @info[name] ||= SourceInfo.new name
          @info[name].path = path if Cog.show_fullpaths?
          @info[name].add_source opt[:source], opt[:type]
        end
      end
      
      # @param plugin [Plugin] name of the plugin
      def add_plugin(plugin, opt={})
        @info[plugin.name] ||= SourceInfo.new plugin.name
        @info[plugin.name].path = plugin.path if Cog.show_fullpaths?
        @info[plugin.name].add_source *plugin.path.cog_source_and_type
      end
      
      def to_a
        w = @info.values.collect {|t| t.override_s.length}.max
        @info.values.sort.collect {|t| t.to_s(w)}
      end
    end
    
  end
end
