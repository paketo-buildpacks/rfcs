# Rake Task Execution

## Proposal

Enable application developers to build images that execute `rake` tasks from a
`Rakefile` at runtime.

## Motivation

[`rake`](https://ruby.github.io/rake/) is a very common script/task execution
framework. Ruby developers will commonly write `rake` tasks to run tests,
execute database migrations, or build release artifacts.

Developers can declare named tasks in a `Rakefile` which can be executed by
running `rake <task>`.  Additionally, `rake` supports the concept of a
"default" task that will be run when simply executing `rake` by itself.

The buildpack should support both of these forms of execution, opting to
support the "default" task as the primary launch process.

## Implementation

Supporting the "default" case can be achieved by setting the launch process to
`rake`. Therefore, when a developer executes their built image, the "default"
task will be executed.

Supporting the "specific" case, where an app developer wishes to execute a task
that is not the default, the buildpack can leverage the [recent
change](https://github.com/buildpacks/rfcs/blob/main/text/0045-launcher-arguments.md)
in behavior of the launcher to support additional, user-provided arguments.

For example, a user may build an application that contains the following `Rakefile`:

```ruby
task default: %w[greet]

desc "Prints a greeting"
task :greet, [:name] do |t, args|
  args.with_defaults(:name => "World")
  puts "Hello, #{args.name}!"
end
```

In this case, the built container image will have a launch command of `rake`
which will enable some useful workflows for the given image.

For example, the user can execute the "default" task:

```
$ docker run -it <image>
Hello, World!
```

Or list the tasks available in the `Rakefile`:

```
$ docker run -it <image> --tasks
rake greet[name]  # Prints a greeting
```

Or execute a task by name:

```
$ docker run -it <image> greet[Alice]
Hello, Alice!
```

### Bundler Support

It is common for Ruby developers to use `bundler` for their applications, and
we should ensure that the `rake` task executes with the gems specified in the
`Gemfile`. Given this concern, the buildpack should modify the launch command
to `bundle exec rake` if the source code contains a `Gemfile` and the `Gemfile`
references `rake`.
