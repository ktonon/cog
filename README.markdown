cog
=====

`cog` is a command line utility that makes it a bit easier to organize a project
which uses code generation.

_It is still in early development! I would not recommend using it until this message gets removed._

Get it
------

From a terminal

```bash
$ gem install cog
```

or in your Gemfile

```ruby
gem "cog", "~> 0.0.18"
```

Prepare a project
-----------------

Consider an existing project with the following directory layout

```
PROJECT_ROOT/
             Makefile
             src/
                 main.cpp
                 ...
```

To use `cog` with this project, you would first open a terminal and change to
the `PROJECT_ROOT` directory. Then enter

```bash
$ cog init
Created Cogfile
Created cog/generators
Created cog/templates
```

Now your project's directory layout will look like this

```
PROJECT_ROOT/
           + Cogfile
             Makefile
             src/
                 main.cpp
                 ...
           + cog/
           +     generators/
           +     templates/
```

The [Cogfile](http://ktonon.github.com/cog/Cog/Config/Cogfile.html) configures
`cog` for use with your project. In short, it tells `cog` where to find generators and templates
and where to put generated source code. It should look like this when you first create
it

```ruby
# All paths are relative to the directory containing this file.

# Define the directory in which to find project generators
project_generators_path 'cog/generators'

# Define the directory in which to find custom project templates
project_templates_path 'cog/templates'

# Define the directory to which project source code is generated
project_source_path 'src'

# Define the default language in which to generated application source code
language 'c++'
```

Generators
----------

A generator is a ruby file which resides in the `project_generators_path`
and performs its work at the time it is required.
A basic generator can be created using the command line tool once a project has
been initialized

```bash
$ cog generator new my_generator
Created cog/generators/my_generator.rb
Created cog/templates/my_generator.txt.erb
```

This is what `my_generator.rb` will look like

```ruby
require 'cog'

class MyGenerator 
  include Cog::Generator
  
  def generate
    @some_context = :my_context_value
    stamp 'my_generator.txt', 'generated_my_generator.txt'
  end
end

MyGenerator.new.generate
```

The important part is the last line. Just requiring this file causes it to run the generation procedure.

The inclusion of the mixin
[Cog::Generator](http://ktonon.github.com/cog/Cog/Generator.html) is a
convenience, but is practically always done (either explicitly or implicitly). It provides an interface for easily
generating source code from templates. The
[stamp](http://ktonon.github.com/cog/Cog/Generator.html#method-i-stamp) method
is particularly useful. If finds an [ERB template](http://www.stuartellis.eu/articles/erb/)
on the template lookup path and renders it to a file under the
`project_source_path`. The `project_templates_path` is on the template lookup
path, and takes the highest precedence (but there are two other possible paths,
see below for more details).

This is what `my_generator.txt.erb` will look like

```erb
This is some context: <%= @some_context %>!
```

Now that you have a generator, you can run it like this

```bash
$ cog run my_generator
Created src/generated_my_generator.txt
```

and the contents of the generated file will be

```
This is some context: my_context_value!
```

You can also list the project's generators like this

```bash
$ cog gen list
my_generator

$ cog gen new fishy
Created cog/generators/fishy.rb
Created cog/templates/fishy.txt.erb

$ cog generator list
fishy
my_generator
```

You can run all of the project's generators by excluding the generator name, like this

```bash
$ cog run
Created src/generated_fishy.txt
```

In this case, both generators are run, but the original `my_generator` hasn't changed, so the generated file `generated_my_generator.txt` will not be touched.

Tools
-----

While its possible to place all the code for your generator in the
`project_generators_path`, you might also consider writing a tool.

A tool is a separately distributed ruby gem which can be registered with `cog`
and contains templates for generator files. A tool should also provide a domain
specific language (DSL) in which the generator files created by the tool are
written.

You can tell `cog` to help you get started writing a tool. For example, if you
wanted to write a command line interface generation tool and call it `cons`, you
would do this

```bash
$ cog tool new cons
Created cons/lib/cons.rb
Created cons/lib/cons/version.rb
Created cons/cog/templates/cons/generator.rb.erb
Created cons/cog/templates/cons/cons.txt.erb
Created cons/Gemfile
Created cons/Rakefile
Created cons/cons.gemspec
Created cons/API.rdoc
Created cons/LICENSE
Created cons/README.markdown
```

In this scenario, the following directory structure would be generated

```
cons/
     cog/
         templates/
                   cons/                 - for templates used by the cons tool
                        generator.rb.erb - a template for making cons generators
                        cons.txt.erb     - default template used by cons generators
     lib/
         cons.rb                         - root tool file provides DSL interface
         cons/
              version.rb                 - adds VERSION to the Cons module
     LICENSE
     README.markdown
     API.rdoc
     cons.gemspec
     Gemfile
     Rakefile

```

Tools are available across multiple projects. The set of available tools is defined by the value of the `COG_TOOLS` environment variable.
The value of this variable is a `:` separated list. Each entry should take one of two formats, either

* Name of root tool file without the `.rb` extension. For example `cons`
* File system path to the root file with the `.rb` extension. For example `/Users/ktonon/cons/lib/cons.rb`

The second form is preferred during development of the tool itself. Both forms are ultimately used in a call to `require`.

You can see a list of the available tools like this

```bash
$ cog tool list
cons
```

As noted before, a tool should contain a template for making generators. In the above example,
that is the `generator.rb.erb` template. You can make a generator using a custom tool like this

```bash
$ cog gen new --tool=cons my_cons
Created cog/generators/my_cons.rb
```

This new generator will look something like this

```ruby
require 'cons'

Cons.widget 'my_cons' do |w|
  w.context = 'this is the context'
end
```

There is no explicit call to generate, but there is still a `generate` method on the `Widget` class
and it is called automatically when the block terminates. Here is what the root tool file `cons.rb` will look like

```ruby
$LOAD_PATH << File.join(File.dirname(__FILE__))
require 'cons/version'
require 'cog'

# Inject this tools templates onto the cog template lookup path
# Do not remove this line
Cog::Config.instance.tool_templates_path = File.expand_path(File.join(__FILE__, '..', '..', 'cog', 'templates'))

# Set the template which is used to create generators for this tool
# Do not remove this line
Cog::Config.instance.tool_generator_template = 'cons/generator.rb'

# Custom cog tool cons 
module Cons 

  # Root of the DSL
  # Feel free to rename this to something more appropriate
  def self.widget(generator_name, &block)
    w = Widget.new generator_name
    block.call w
    w.generate
    nil
  end

  # Root type of the DSL
  # You'll want to rename this to something more meaningful
  # and probably place it in a separate file.
  class Widget
    
    include Cog::Generator
    
    attr_accessor :context
    
    def initialize(generator_name)
      @generator_name = generator_name
    end
    
    def generate
      stamp 'cons/cons.txt', "generated_#{@generator_name}.txt"
    end
  end
end
```

API Documentation
-----------------

To get the most out of `cog` you'll need to refer to the [API docs](http://ktonon.github.com/cog/).
