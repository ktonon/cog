require 'cog/mixins/uses_templates'
require 'cog/config'

module Cog
  
  class TemplateController
    
    include Mixins::UsesTemplates

    # Create a ruby generator from a template.
    #
    # === Parameters
    # * +ruby_template+ - name of the ruby template. This is a template
    #   which is distributed in the cog gem. It is relative to
    #   <tt>templates/</tt>
    # * +generator_name+ - name of the generator
    #
    # === Options
    # * <tt>:language</tt> - only <tt>'c++'</tt> is accepted at this time
    # * <tt>:package</tt> - slash (/) separated path which will prefix
    #   +generator_name+
    def stamp_generator(ruby_template, generator_name, opt={})
      template = File.join Config.gem_dir, 'templates', "#{ruby_template}.rb"
      target = "#{generator_name}.rb"
      target = File.join opt[:package], target if opt[:package]
      target = File.join 'generators', target
      stamp template,
        :target => target,
        :target_type => :cog,
        :use_absolute_path => true
    end

    # Create an app module template from a template.
    #
    # === Parameters
    # * +source_template+ - name of the source template. This is a template
    #   which is distributed in the cog gem. It is relative to
    #   <tt>templates/{language}/</tt>, where language is specified by the
    #   <tt>:language</tt> option. Do not include any file extension such as
    #   <tt>.h</tt> (the <tt>:language</tt> will also determine this)
    # * +module_name+ - name of the module. For languages like <tt>:c++</tt>,
    #   two templates will be generated (i.e. one <tt>.h</tt> and one
    #   <tt>.cpp</tt>)
    #
    # === Options
    # * <tt>:language</tt> - only <tt>'c++'</tt> is accepted at this time
    # * <tt>:package</tt> - slash (/) separated path which will prefix
    #   +module_name+
    def stamp_module(source_template, module_name, opt={})
      lang = opt[:language] || 'c++'
      extensions_for_language(lang).each do |ext|
        template = File.join Config.gem_dir, 'templates', lang, "#{source_template}.#{ext}"
        target = "#{module_name}.#{ext}"
        target = File.join opt[:package], target if opt[:package]
        target = File.join 'templates', target
        stamp template,
          :target => target,
          :target_type => :cog,
          :use_absolute_path => true
      end
    end
    
  private
    def extensions_for_language(lang)
      case lang.to_s
      when /(cpp|c\+\+)/i
        [:h, :cpp]
      else
        []
      end
    end
  end
  
end
