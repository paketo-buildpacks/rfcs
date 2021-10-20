# Go BOM Generation

_NOTE: We may wish to move this RFC under the go-build directory if/when it is
approved. We are keeping it here while the discussion is open in order to
preserve history._

## Summary

Add support for the generation of the Bill of Materials in the Go Language
Family in order to provide entries for modules installed during the build
process that can be found on the final application image.

## Motivation

Previously, the
[Node.JS Module BOM buildpack](https://github.com/paketo-buildpacks/rfcs/blob/main/text/nodejs/0013-install-bom.md)
was developed to create a BOM for the nodejs language family. We would now like
to add similar support for BOM generation in the Go language family.

We propose modifying the [`go-build` buildpack](https://github.com/paketo-buildpacks/go-build)
to add BOM generation as an optional feature during the build process.
Additionally, we propose to add a new buildpack called `cyclonedx-gomod` which
provides the `cyclonedx-gomod` executable for this process to run.

We propose to support generating BOMs only for projects which utilize vendoring
via `go mod`. At this time we do not propose to support any other vendoring
solutions (e.g. `dep` or files copied directly into the `vendor` directory
without a `go.mod` file). Supporting other vendoring solutions could be a future
RFC, if we discover a clear requirement for this. The primary reason for this is
that the `cyclonedx-gomod` tool (see the Implementation section below) does not
support generating BOMs for these alternative vendoring mechanisms.

## Implementation

### Tool details

The Bill of Materials that will result should be an accurate accounting of all
the modules that are defined and installed by `go mod`.

There already exists a tool called [CycloneDX Gomod](https://github.com/CycloneDX/cyclonedx-gomod)
which is an official CycloneDX-supported tool that creates valid CycloneDX BOMs
for Go applications. CycloneDX is a BOM format supported by the OWASP
Foundation, and is a serious contender (at the time of this RFC creation) as a
format we will eventually support.

The CycloneDX Go Module tool is available as a pre-built binary for multiple
platforms, and also it can easily be installed via `go install
github.com/CycloneDX/cyclonedx-gomod`.

This tool supports three different cases of BOM generation:

1. `app`: Include only those modules that the target application actually
   depends on. Modules required by tests or packages that are not imported by
   the application are not included. Build constraints are evaluated, which
   enables a very detailed view of what's really compiled into an application's
   binary.
2. `mod`: Include the aggregate of modules required by all packages in the
   target module. This optionally includes modules required by tests and test
   packages. Build constraints are NOT evaluated, allowing for a "whole picture"
   view on the target module's dependencies.
3. `bin`: Offers support of generating rudimentary SBOMs from binaries built
   with Go modules.

Of these, we are only interested in `app`. There are a few reasons why `mod` and
`bin` are not suitable:

* The buildpacks do not currently support building modules without an associated
  executable (i.e. libraries) which is the primary use-case for `mod`.
* The BOM produced by the `mod` command contains less information than the BOM
  produced by the `app` command.  (e.g. the `mod` command does not include
  license info, or detailed info for each file).
* The `mod` command does not respect flags provided to the `go build` process at
  build time e.g. `CGO_ENABLED`, `GOFLAGS`.
* The `bin` command is for pre-built executables, which is unnecessary for the
  buildpack as it has access to the source code
* The `bin` command produces less detailed output than `app` as it does utilize
  the source code if it is present.

The output BOM contains the following fields for each module:

* name,
* version,
* hash,
* source URI,
* license ID,
* and package URL

Note: The `license` field can be retrieved when the flag `-licenses` is passed to the command.

Almost all of fields that we aim to support per
[the Paketo BOM RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0033-bill-of-materials.md#overall-schema)
are available. The only one that is not available is `description`, and this is
because there is no standard way to capture this information in Go projects (as
compared with other languages like nodejs and rust, where the package
description files contain a field for this metadata). See unresolved questions
below.

In order to support this tool in both the online and offline cases, we will host
the binary tool on the
[dep-server](https://github.com/paketo-buildpacks/dep-server).

### Performance

The addition of this tool to the language family order groupings might have an
impactful change to the overall performance of the buildpacks.

Performance metrics are still TBD, but for a typical project (e.g.
[`pack`](https://github.com/buildpacks/pack)) we observe that it takes about
10-30 seconds to construct a BOM.

We can investigate ways to improve this performance. In the meantime, we propose
including an environment variable: `BP_DISABLE_MODULE_BOM` (which defaults to
`false`) to skip BOM generation if it takes an unacceptable duration.

### Limitations

The `cyclonedx-gomod` tool requires that the app being analyzed is a valid `git`
repository, as it uses `git` for version detection. We believe that this is not
a significant issue, as `git` is a common VCS. The authors of `cyclonedx-gomod`
imply they might be open to support for other VCSs if the need arose.

The main limitation of the `git` repository requirement is if the app being
analyzed does not have version control at all.  For example, if the app is part
of a parent repository that is not uploaded in its entirety to `pack`. In this
case the entire parent repository must be uploaded to `pack`, or some other
option must be considered (e.g. using git submodules).

The `cyclonedx-gomod` tool requires a `go.mod` file - it fails to run without
one. So, if we wish to support vendoring directly without a `go.mod` file we
will need to explore an alternative tool, or find a way for `cyclonedx-gomod` to
support this.

### Language Family Changes

There will be a single new buildpack called `cyclonedx-gomod` which will
provide the `cyclonedx-gomod` executable. It will install this binary onto the
`$PATH` which makes it available for the `go-build` buildpack to use during the
`build` phase when generating a BOM.

This buildpack will always pass detection, and will `provide` the dependency
`cyclonedx-gomod` with no version. This buildpack will require nothing.

This new buildpack will behave similarly to the
[`dep`](https://github.com/paketo-buildpacks/dep) buildpack.

The `go-build` buildpack will optionally `require` this `cyclonedx-gomod`
dependency, depending on whether it will run BOM generation. Pseudo-code for
this optional `require` looks as follows:

```
if BP_DISABLE_MODULE_BOM is unset/false and go.mod file exists:
    require: go-dist, cyclonedx-gomod
else:
    require: go-dist
```

This same logic will be utilized during the `build` phase of the `go-build`
buildpack to determine if the BOM should be generated.

### Full order group

As the `cyclonedx-gomod` tool only supports `go.mod`, we will only modify the
order group that corresponds to this path. The addition of the new
`cyclonedx-gomod` buildpack is highlighted for clarity.

<pre>
[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true
    version = "2.4.2"

  [[order.group]]
    id = "paketo-buildpacks/go-dist"
    version = "0.7.0"

  [[order.group]]
    id = "paketo-buildpacks/go-mod-vendor"
    version = "0.3.1"

  <b>[[order.group]]</b>
    <b>id = "paketo-buildpacks/cyclonedx-gomod"</b>
    <b>version = "x.y.z"</b>

  [[order.group]]
    id = "paketo-buildpacks/go-build"
    version = "0.4.1"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    optional = true
    version = "4.4.1"

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true
    version = "3.2.2"

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true
    version = "3.2.2"
</pre>

#### Detection

There will be no changes to detection for any existing buildpacks in the Go
language family. As mentioned above, the new `cyclonedx-gomod` buildpack will
always pass detection and provide `cyclonedx-gomod` with no version.

#### Build

The new `cyclonedx-gomod` buildpack build phase will perform the following:

1. Perform the BOM dependency tool retrieval from the dep-server. It will get
   added to a build-time layer. It will contribute a BOM entry for the tool
   itself on the `build.toml` `[bom]` section. This will behave similarly to the
   `dep` buildpack.

The build phase in the `go-build` buildpack will perform the tasks highlighted
below. If there is no `go.mod` file present, or the `BP_DISABLE_MODULE_BOM`
environment variable is set to `true`, the `go-build` build phase will skip BOM
generation entirely.

1. Parse the `BP_DISABLE_MODULE_BOM` environment variable, skip BOM generation
   if this variable is set to `true`. Continue with BOM generation if this
   variable is set to `false` or is unset.

2. Determine if there is a `go.mod` file present; skip BOM generation if this
   file is absent. There is no need to parse this file or check its integrity.

3. Execute BOM generation with the installed tool via the `cyclonedx-gomod app
   -json -files -licenses -main <target> -o bom.json` command in the root
   directory of the application. The `<target>` is determined by the
   `BP_GO_TARGETS` command in the same manner as the existing build phase of the
   `go-build` buildpack. If multiple targets are provided, the tool is invoked
   for each target and the resultant BOMs are merged. We opt to merge the BOMs
   to keep the same structure as the node buildpack (which does not support
   building multiple targets), and can consider changing the structure to
   support multiple top-level targets in the future if the need arises.

4. Parse the resulting JSON output from the command above, and map each entry into a
   [`packit.BOMEntry`](https://github.com/paketo-buildpacks/packit/blob/fc612d69a93a6f36f4fe97a25076cc8eddf0b544/bom.go#L10) type.
   Merge the entries from multiple targets (see above).

5. Continue with the build process as before.

## Rationale

Performing BOM generation with the CycloneDX Go Module tool has some advantages.
First, it minimizes the extra domain knowledge we would have to develop and
maintain a program to recurse through all the go modules and their dependencies.

Second, there is a high likelihood that we will support CycloneDX as a BOM
format in the future. In that case, we can simply run the tool and return that
BOM without any additional formatting or conversion. Going this route will
minimize the change needed down the road, and we can get a CycloneDX output we
can feel confident about.

## Alternatives

An alternative to the option to using the CycloneDX BOM tool would be to
hand-create the BOM as described. We could go through each go module directory,
pull information out of each `go.mod` file and then build out our own BOM with
that data. This is a viable option if installing a tool is not a reasonable
choice.

An alternative to performing this BOM generation process in the `go-build`
buildpack could be to perform this process in the `build` phase of the
`cyclonedx-gomod` buildpack. However, this has multiple drawbacks, including a
tight, implicit, coupling between the `cyclonedx-gomod` buildpack and the
`go-build` buildpack, particularly around environment variables like
`BP_GO_TARGETS` and other build-time environment variables that are evaluated by
both `cyclonedx-gomod` and the `go build` processes.

## Unresolved Questions and Bikeshedding

* Is the `description` field something that is required by the BOM Standard
  mentioned in the Paketo BOM RFC? (The field mentioned in the RFC is `summary`,
  which is the same as the description)
	* If this is required, is there an idiomatic way to capture the package
	  description in Go applications and libraries?
* Should the dependency be called `cyclonedx-gomod` or something more abstract like
  `bom-generator`?
  * The specific dependency is simpler to reason about both at the
    `requires`/`provides` API level and in the code in `go-build` buildpack. We
    also have no evidence that we will ever support (or be able to support)
    multiple golang BOM generators.
  * The more abstract name allows for different implementations of
    BOM-generation without making a breaking change to the `requires`/`provides`
    API.

## Resources

* [Paketo BOM RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0033-bill-of-materials.md#overall-schema)
* Work in progress [Cloud Native Buildpacks BOM Format RFC](https://github.com/buildpacks/rfcs/pull/166)
