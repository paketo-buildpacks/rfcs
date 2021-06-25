# Compilation

## Proposal

The compilation mechanism for Go application source code will be the `go build`
tool. This aligns with the
[guidance](https://golang.org/cmd/go/#hdr-Compile_packages_and_dependencies) in
the Go documentation.

Specifically, source is compiled with the following command:

```
export GOCACHE=[layer directory]
go build \
  -o [output directory] \
  -buildmode pie \
  [-mod vendor] \
  [targets]
```

### Output Directory
The `go build` tool should output the compilation results to a specific output
directory. From the Go documentation for `go build`:

> The -o flag forces build to write the resulting executable or object to the
> named output file or directory, instead of the default behavior described in
> the last two paragraphs. If the named output is a directory that exists, then
> any resulting executables will be written to that directory.

In our case, this output directory will be the `bin` directory in a layer
managed by the buildpack. This means that the compiled executables will
ultimately end up on the `$PATH` as explained in the [Layer
Paths](https://github.com/buildpacks/spec/blob/main/buildpack.md#layer-paths)
section of the Buildpack Spec.

### Build Mode
Additionally, we are specifying that it should compile using the
"position-independent executable" or `pie` [build
mode](https://golang.org/cmd/go/#hdr-Build_modes).

Position-independent executables can be executed by the kernel with random
internal memory locations for the program code.  This randomization increases
the difficulty of executing memory overflow exploits against the running
program. As there are no guarantees about the location of any function in
memory, modifications to that code become considerably more difficult.

The tradeoff chosen is to produce a more secure executable at the expense of a
slightly larger filesystem/memory footprint and mild performance loss.

### Targets
The `go build` tool can compile multiple programs at the same time. We should
leverage this feature to allow application developers to build images that
contain multiple compiled executables.

As explained in the Go documentation for [package lists and
patterns](https://golang.org/cmd/go/#hdr-Package_lists_and_patterns), a list of
packages is usually a list of import paths. However, for our case, we should
only be compiling code that is local to the filesystem. The documentation explains that,

> An import path that is a rooted path or that begins with a . or .. element is
> interpreted as a file system path and denotes the package in that directory.

The buildpack will support specifying multiple targets through the
`buildpack.yml` file in a form like the following:

```yaml
---
go:
  targets:
  - ./some-target
  - ./other-target
````

Targets must be a list of paths relative to the root directory of the source
code. The buildpack will ensure these paths are prefixed with a `./` so that
the `go build` tool will identify them as paths local to the filesystem.

### Vendoring Support
It is expected that other buildpacks in the Go language family will provide
external packages through a vendoring mechanism. The expectation in all of
these cases is that the build command use the vendored code preferentially over
downloading dependencies directly.

For cases where a `vendor` directory is provided at the root of the target, the
`go build` tool will search that directory for imported packages to compile as
outlined in the Go documentation on [vendor
directories](https://golang.org/cmd/go/#hdr-Vendor_Directories).

For code that also uses Go modules, the `go build` command will be appended
with the `-mod vendor` argument so that packages will be "loaded from the
vendor directory instead of accessing the network" as defined in the Go
documentation for [Modules and
vendoring](https://golang.org/cmd/go/#hdr-Modules_and_vendoring). In that
documentation, it further outlines that this behavior is the default for Go
1.14 and higher, meaning that it does not need to be explicitly included in the
`go build` command when using those versions. As the buildpack may currently
support versions of Golang older than 1.14, we will continue to include the
argument explicitly.

### GOCACHE

As described in the Go documentation for [build and test
caching](https://golang.org/cmd/go/#hdr-Build_and_test_caching), the `go build`
command will cache build outputs for reuse on subsequent invocations.  As most
programs change incrementally, reusing outputs from this cache can provide a
considerable compilation speed boost when rebuilding an application.

To support this compilation speed boost, the buildpack will allocate a layer
marked as `cache = true` in the Layer Content Metadata file so that the layer
will be persisted to subsequent builds and set the `$GOCACHE` environment
variable to that layer path during the execution of the `go build` tool.

## Motivation

The Go Build buildpack has a number of usecases that need support in a
comprehensive compilation process. The `go build` command outlined above meets
the needs of these cases, including:

* compiling the source into an executable that is addressable on the `$PATH`
* providing a more secure compiled artifact
* compiling multiple programs in a single build invocation
* vendoring dependencies alongside source code
* providing a performant compilation process using caching
