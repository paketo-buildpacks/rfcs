# Ensure Command

## Proposal

The [Dep documentation](https://golang.github.io/dep/docs/daily-dep.html)
outlines several commands for use, but the primary command invoked during
normal use of the package manager is `dep ensure`.

The `dep ensure` command will perform several tasks when it is invoked. The
documentation describes this as follows:

> Hey dep, please make sure that my project is in sync: that `Gopkg.lock`
> satisfies all the imports in my project, and all the rules in `Gopkg.toml`, and
> that `vendor/` contains exactly what `Gopkg.lock` says it should.

Furthermore, it outlines that invoking `dep ensure` will bring the project into
a stable state, which is ideal for the workings of this buildpack:

> `dep ensure` is almost never the wrong thing to run; if you're not sure
> what's going on, running it will bring you back to safety ("the nearest
> lilypad"), or fail informatively.

Given this information, this buildpack should invoke a package installation
process that is the equivalent of the following shell script:

```
export GOPATH=[temporary directory]
export DEPCACHEDIR=[layer directory]
dep ensure
```

This process will be invoked from within the application source code directory.
As a prerequisite for running this command, the buildpack will detect that the
source code contains a `Gopkg.toml` file. Optionally, there may be a
`Gopkg.lock` file that outlines specific versions of the dependencies to be
packaged. The `dep ensure` command will automatically obey the contents of the
`Gopkg.lock` file if it is present.

After running `dep ensure` the application source code directory will be
populated with a `vendor` directory containing the contents of all packages
required by the application. If there was no `Gopkg.lock` file in the original
source, that file would now exist with a populated set of version mappings for
each dependency.

The `vendor` directory will then be used to aid in the compilation of the
program in the [`go-build`
buildpack](https://github.com/paketo-buildpacks/go-build).

### GOPATH

The `dep` tool requires that the source code it operates on be located in a
working GOPATH directory structure. As the lifecycle places the source code
into a root `/workspace` directory, a GOPATH will need to be constructed and
the source code copied to this new location before invoking the `dep ensure`
command.

Once the command successfully completes, the results of that invocation
(`vendor` and `Gopkg.lock`) can be copied back into the original `/workspace`
directory.

### DEPCACHEDIR

As outlined in the [`dep`
glossary](https://golang.github.io/dep/docs/glossary.html#local-cache), the
`dep` tool maintains a cache of upstream sources. This cache can be used to
increase the performance of the `dep ensure` command by removing the need to
make a network call to retrieve upstream source code before copying the
required dependencies into the `vendor` directory.

To support this performance boost, the buildpack will allocate a layer marked
as `cache = true` in the Layer Content Metadata file so that the layer will be
persisted to subsequent builds. Additionally, the path to this layer on disk
will be assigned to the `$DEPCACHEDIR` environment variable and made available
to the `dep ensure` command on invocation.

## Motivation

The primary case for executing the `dep ensure` command as outlined above is
that it will bring the application to a safe checkpoint for the dependencies
required. Additionally, including a cache via the `DEPCACHEDIR` environment
variable will enable the buildpack to provide performant rebuilds of the
dependencies provided.
