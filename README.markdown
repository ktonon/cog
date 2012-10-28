cog
=====

`cog` is a command line utility that makes it a bit easier to organize a project
which uses code generation.

_It is still in early development! I would not recommend using it until this message gets removed._

Get it
------

From a terminal

```bash
gem install cog
```

or in your Gemfile

```ruby
gem "cog", "~> 0.0.10"
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

To use `cog` with this project, you would first open a terminal and change to the `PROJECT_ROOT` directory. Then enter

```bash
cog init
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

The [Cogfile](http://ktonon.github.com/cog/Cog/Cogfile.html) configures `cog` for use with your project. In short, it tells `cog` where to find sources and where to put generated code. It should look like this when you first create it

```ruby
# All paths are relative to the directory containing this file.

# The directory in which to place Ruby generators and +ERB+ templates.
cog_dir 'cog'

# The directory in which to place generated application code.
app_dir 'src'

# The default language in which to generate source code.
language 'c++'
```

Write a tool
------------

While its possible to place all the code for your generator in the `cog/generators` directory, you might also consider writing a tool.

A tool is a stand-alone domain specific generator. You can tell `cog` to help you get started writing a tool. For example, if you wanted to write a command line interface generation tool and call it `cons`, you would do this

```bash
cog tool cons
```

In this scenario, the following directory structure would be generated

```
cons/
     bin/
         cons                            - command line interface
     cog/
         templates/
                   cons/                 - for templates used by the cons tool
                        generator.rb.erb - a template for the default generator
     lib/
         cons.rb                         - contains the Cons module and boilerplate tool code
         cons/
              version.rb                 - adds VERSION to the Cons module
     cons.gemspec
     Gemfile
     LICENSE
     Rakefile
     README.markdown

```

API Documentation
-----------------

To get the most out of `cog` you'll need to refer to the [API docs](http://ktonon.github.com/cog/).
