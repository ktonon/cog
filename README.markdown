cog
=====

This is a utility to help you write code generators. _It is still in early development_.

Quick Start
-----------

Install the gem:

```bash
gem install cog
```

Change to the root directory of a project in which you'd like to use a code
generator and do this:

```bash
cog project
```

This will create a `Cogfile` which is used to configure `cog` for your project.
It should look something like this:

```ruby
# All paths are relative to the directory containing this file.

# The directory in which to find ERB template files.
template_dir 'templates'

# The directory in which application code can be found. This is where
# generated code will go. Probably along side non-generated code.
code_dir 'src'
```
