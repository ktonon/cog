require 'cog/helpers/string'
require 'rainbow'

module Cog
  module Helpers
    
    # @api developer
    class TemplateInfo
      attr_reader :name
      attr_accessor :path
      
      def initialize(name)
        @sources = []
        @source_types = []
        @name = name
      end
      
      def add_source(source, source_type)
        @sources << source
        @source_types << source_type
      end
      
      def style(text, type)
        case type
        when :built_in
          text.color :cyan
        when :tool
          text.color :yellow
        when :project
          text.color(:white).bright
        end
      end
      
      def override_s(width=nil)
        colorless = "[#{@sources.join ' < '}]"
        if width
          x = @sources.zip(@source_types).collect {|s, t| style s, t}
          "[#{x.join ' < '}]" + " " * (width - colorless.length)
        else
          colorless
        end
      end
      
      def <=>(other)
        (@path || @name) <=> (other.path || other.name)
      end
      
      def to_s(override_column_width)
        "#{override_s override_column_width} #{style @path || @name, @source_types.last}"
      end
    end
    
    # @api developer
    class CascadingTemplateSet
      def initialize
        @templates = {}
      end
      
      def add_templates(source, source_type, root, opt={})
        Dir.glob("#{root}/**/*.erb") do |path|
          name = path.relative_to(root).slice(0..-5)
          @templates[name] ||= TemplateInfo.new name
          @templates[name].path = path if opt[:verbose]
          @templates[name].add_source source, source_type
        end
      end
      
      def to_a
        w = @templates.values.collect {|t| t.override_s.length}.max
        @templates.values.sort.collect {|t| t.to_s(w)}
      end
    end
    
  end
end
