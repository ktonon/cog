## 0.3.3 - April 18, 2013

- Updated for Ruby 2.0

## 0.3.1 - January 5, 2013

### New features

- [Keeps][] preserve manually maintained code segments in a generated file

## 0.3.0 - December 29, 2012

### Backwards incompatible changes

- Changes to the `Cogfile` interface
  * `project_source_path` renamed to `project_path`
  * `project_generators_path` renamed to `generator_path`
  * `project_templates_path` renamed to `template_path`
- Tools have been renamed to plugins
- <tt>cog_tool.rb</tt> is no longer used, plugins are configured using a [Cogfile][] instead
  * that `Cogfile` should contain a call to [autoload_plugin][] and [stamp_generator][]
- Generator scripts should not include these lines anymore
  * <tt>require 'cog'</tt>
  * <tt>include Cog::Generator</tt>
  * Instead, they are evaluated as instances of [GeneratorSandbox][], which already includes the [Generator][] mixin
- Generator scripts for plugins should not `require` the plugin anymore
  * The plugin module should be made available to the [GeneratorSandbox][] via [autoload_plugin][]
  
### New features

- `cog` will evaluate a chain of cogfiles in this order
  * A built-in cogfile that comes with the `cog` gem which points to built-in generators, templates, and plugins
  * A user cogfile, that is created in the <tt>${HOME}/.cog</tt> directory. Shared generators, templates, and plugins can be configured here
  * Cogfiles for any discovered plugins
  * The project cogfile, if operating in the context of a project
- Languages are defined in cogfiles via the [LanguageDSL][]
- Plugins distributed as gems are automatically discovered, no need to set an environment variable anymore
- <tt>--force-override</tt> is no longer needed to override a template

[gem]:https://rubygems.org/gems/cog
[docs]:http://ktonon.github.com/cog/frames.html
[changelog]:https://github.com/ktonon/cog/blob/master/CHANGELOG.md
[ERB]:http://www.stuartellis.eu/articles/erb/
[DSL]:http://jroller.com/rolsen/entry/building_a_dsl_in_ruby

[Cogfile]:http://ktonon.github.com/cog/Cog/DSL/Cogfile.html
[Generator]:http://ktonon.github.com/cog/Cog/Generator.html
[GeneratorSandbox]:http://ktonon.github.com/cog/Cog/GeneratorSandbox.html
[LanguageDSL]:http://ktonon.github.com/cog/Cog/DSL/LanguageDSL.html
[Keeps]:https://github.com/ktonon/cog#keeps

[autoload_plugin]:http://ktonon.github.com/cog/Cog/DSL/Cogfile.html#autoload_plugin-instance_method
[comment]:http://ktonon.github.com/cog/Cog/Generator/Filters.html#comment-instance_method
[embed]:http://ktonon.github.com/cog/Cog/Generator.html#embed-instance_method
[generator_path]:http://ktonon.github.com/cog/Cog/Config.html#generator_path-instance_method
[plugin_path]:http://ktonon.github.com/cog/Cog/Config.html#plugin_path-instance_method
[project_path]:http://ktonon.github.com/cog/Cog/Config/ProjectConfig.html#project_path-instance_method
[project_plugin_path]:http://ktonon.github.com/cog/Cog/Config/ProjectConfig.html#project_plugin_path-instance_method
[stamp]:http://ktonon.github.com/cog/Cog/Generator.html#method-i-stamp
[stamp_generator]:http://ktonon.github.com/cog/Cog/DSL/Cogfile.html#stamp_generator-instance_method
[template_path]:http://ktonon.github.com/cog/Cog/Config.html#template_path-instance_method
[warning]:http://ktonon.github.com/cog/Cog/Generator/LanguageMethods.html#warning-instance_method
