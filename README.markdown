cog
=====

This is a utility to help you write code generators. _It is still in early development_.

See also the [API docs](http://ktonon.github.com/cog/).

Quick Start
-----------

Install the gem:

```bash
gem install cog
```

Change to the root directory of a project in which you'd like to use a code
generator and do this:

```bash
cog init
```

This will create a `Cogfile` which is used to configure `cog` for your project.
It should look something like this:

```ruby
# All paths are relative to the directory containing this file.

# The directory in which to place Ruby generators and +ERB+ templates.
cog_dir 'cog'

# The directory in which to place generated application code.
app_dir 'src'
```
