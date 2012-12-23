module Cog
  module Helpers
    
    # @api developer
    class SourceInfo
      attr_reader :name
      attr_accessor :path
      
      def initialize(name)
        @sources = []
        @types = []
        @name = name
      end
      
      def add_source(source, type)
        @sources << source
        @types << type
      end
      
      def style(text, type)
        case type
        when :built_in
          text.color :cyan
        when :user
          text.color(:black).background(:cyan)
        when :plugin
          text.color :yellow
        when :project
          text.color(:white).bright
        else
          text
        end
      end
      
      def override_s(width=nil)
        colorless = "[#{@sources.join ' < '}]"
        if width
          x = @sources.zip(@types).collect {|source, type| style source, type}
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
        @templates = {}
      end

      # @option opt [String] :source (nil) the name of the source
      # @option opt [Symbol] :type (nil) must be one of <tt>:built_in</tt>, <tt>:user</tt>, <tt>:plugin</tt>, or <tt>:project</tt>
      # @option opt [String] :root_dir (nil) directory in which to look for sources
      # @option opt [String] :ext (nil) file name extensions to search for. Glob patterns are acceptable.
      def add_sources(opt={})
        Dir.glob("#{opt[:root_dir]}/**/*.#{opt[:ext]}") do |path|
          name = path.relative_to(opt[:root_dir]).slice(0..-5)
          @templates[name] ||= SourceInfo.new name
          @templates[name].path = path if opt[:verbose]
          @templates[name].add_source opt[:source], opt[:type]
        end
      end
      
      def to_a
        w = @templates.values.collect {|t| t.override_s.length}.max
        @templates.values.sort.collect {|t| t.to_s(w)}
      end
    end
    
  end
end
