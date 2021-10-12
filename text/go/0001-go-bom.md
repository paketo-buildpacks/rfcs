# Go BOM Generation

## Summary

Add support for the generation of the Bill of Materials in the Go Language Family in order to provide entries for
modules installed during the build process that can be found on the final app image.

## Motivation

As a part of an initiative to provide a Bill of Materials (BOM) for all the Paketo Language Family Buildpacks, in
previous months
the [Node.JS BOM Module](https://github.com/paketo-buildpacks/rfcs/blob/main/text/nodejs/0013-install-bom.md) was
developed.

We would like to add support for BOM generation in the Go language family. We would like to create a new buildpack to
provide this. We do not anticipate the need for changes to other buildpacks in the language family.

We propose to support generating BOMs only for projects which utilize vendoring via `go mod`. At this time we do not
propose to support any other vendoring solutions
(e.g. `dep` or files copied directly into the `vendor` directory without a
`go.mod` file). Extending the new buildpack to support to other vendoring solutions could be a future RFC, if we
discover a clear requirement for this.

## Implementation

### Tool details

The Bill of Materials that will result should be an accurate accounting of all the modules that are defined and
installed by `go modules`.

There already exists a tool called [CycloneDX Gomod](https://github.com/CycloneDX/cyclonedx-gomod) which is an official
CycloneDX-supported tool that creates valid CycloneDX BOMs for Go applications. CycloneDX is a BOM format supported by
the OWASP Foundation, and is a serious contender (at the time of this RFC creation) as a format we will eventually
support.

The CycloneDX Go Module tool is available as a pre-built binary for multiple platforms, and also it can easily be
installed via `go install github.com/CycloneDX/cyclonedx-gomod`.

This tool supports three different cases of BOM generation:

1. `app`: Include only those modules that the target application actually depends on. Modules required by tests or
   packages that are not imported by the application are not included. Build constraints are evaluated, which enables a
   very detailed view of what's really compiled into an application's binary.
2. `mod`: Include the aggregate of modules required by all packages in the target module. This optionally includes
   modules required by tests and test packages. Build constraints are NOT evaluated, allowing for a "whole picture" view
   on the target module's dependencies.
3. `bin`: Offers support of generating rudimentary SBOMs from binaries built with Go modules.

Of these, we are only interested in `app`. There are a few reasons why `mod` and `bin` are not suitable:

* The buildpacks do not currently support building modules without an associated
executable (i.e. libraries) which is the primary use-case for `mod`.
* The BOM produced by the `mod` command contains less information than the BOM produced by the `app` command.
(e.g. the `mod` command does not include license info, or detailed info for each file).
* The `mod` command does not respect flags provided to the `go build`
  process at build time e.g. `CGO_ENABLED`, `GOFLAGS`.
* The `bin` command is for pre-built executables, which is unnecessary for the buildpack as it has access to the source code
* The `bin` command produces less detailed output than `app` as it does utilize the source code if it is present.

The output BOM contains the following fields for each module:

* name,
* version,
* hash,
* source URI,
* license ID,
* and package URL

Note: The `license` field can be retrieved when the flag `-licenses` is passed to the command.

Almost all of fields that we aim to support
per [the Paketo BOM RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0033-bill-of-materials.md#overall-schema)
are available. The only one that is not available is `description`, and this is because there is no standard way to
capture this information in Go projects (as compared with other languages like nodejs and rust, where the package
description files contain a field for this metadata). See unresolved questions below.

In order to support this tool in both the online and offline cases, we will host the binary tool on
the [dep-server](https://github.com/paketo-buildpacks/dep-server).

### Performance

The addition of this tool to the language family order groupings might have an impactful change to the overall
performance of the buildpacks.

Performance metrics are still TBD, but for a typical project (e.g. `pack`) we observe that it takes about 10-30 seconds
to construct a BOM.

We can investigate ways to improve this performance.

### Limitations

The `cyclonedx-gomod` tool requires that the app being analyzed is a valid `git`
repository, as it uses `git` for version detection. We believe that this is not
a significant issue, as `git` is a common VCS. The authors of `cyclonedx-gomod`
imply they might be open to support for other VCSs if the need arose.

The main limitation of the `git` repository requirement is if the app
being analyzed does not have version control at all.
For example, if the app is part of a parent repository that is not uploaded in its
entirety to `pack`. In this case the entire parent repository must be uploaded
to `pack`, or some other option must be considered (e.g. using git submodules).

### Language Family Additions

Using the CycloneDX tool to generate the BOM will involve some changes to the Go language family buildpack order groups
as follows:

* A single BOM generation buildpack will be added. It's primary functions are:
    * perform the BOM dependency tool retrieval from the dep-server,
    * execute BOM generation with the tool (`cyclonedx-gomod app -o bom.json`), and
    * contribute the BOM to the `launch.toml` `[bom]` label.

* For the Go Mod buildpack order group, the BOM generation buildpack will run directly before the `go-build` buildpack.

#### Detection

The Go Module BOM Generator CNB will pass detection if there is valid `go.mod` file and the repository is a valid `git` repository with the following contract:

* Requires {`go-dist`} during `build`
* Provides none

#### Build

The build phase will perform a few tasks as mentioned above.

1. Perform the BOM dependency tool retrieval from the dep-server. It will get added to a build-time layer. It will
   contribute a BOM entry for the tool itself on the `build.toml` `[bom]` section.

2. Execute BOM generation with the installed tool via the
`cyclonedx-gomod app -json -files -licenses -main <target> -o bom.json` command in the root
   directory of the application. The `<target>` is determined by the
   `BP_GO_TARGETS` command in the same manner as the `go-build` buildpack. If
   multiple targets are provided, the tool is invoked for each target and the
   resultant BOMs are merged. We opt to merge the BOMs to keep the same
   structure as the node buildpack (which does not support building multiple
   targets), and can consider changing the structure to support multiple
   top-level targets in the future if the need arises.

3. Parse the resulting JSON output from the command above, and map each entry into a
   [`packit.BOMEntry`](https://github.com/paketo-buildpacks/packit/blob/fc612d69a93a6f36f4fe97a25076cc8eddf0b544/bom.go#L10) type.
   Merge the entries from multiple targets (see above).

4. Clean up the generated BOM file

#### Potential Future Optimizations

Given future user interest in a way to opt out of this buildpack beyond a custom order grouping, an optimization that
could be made is the inclusion of a
`BP_DISABLE_MODULE_BOM` environment variable that can be set during container build-time. The default value for this (when unset) is `false`.

## Rationale

Performing BOM generation with the CycloneDX Go Module tool has some advantages. First, it minimizes the extra domain
knowledge we would have to develop and maintain a program to recurse through all the go modules and their dependencies.

Second, there is a high likelihood that we will support CycloneDX as a BOM format in the future. In that case, we can
simply run the tool and return that BOM without any additional formatting or conversion. Going this route will minimize
the change needed down the road, and we can get a CycloneDX output we can feel confident about.

## Alternatives

An alternative to the option to using the CycloneDX BOM tool would be to hand-create the BOM as described. We could go
through each go module directory, pull information out of each `go.mod` file and then build out our own BOM with that
data. This is a viable option if installing a tool is not a reasonable choice.

An alternative to performing all of these steps in a separate buildpack would be to add the CycloneDX tool installation
as a step in the Go Build buildpack, and then run BOM creation alone in a buildpack before the start commands. This is
less than ideal because it's not transparent or intuitive to install it during the go specific build process. It makes
more sense to separate all module BOM creation logic into its own buildpack, so that users may easily opt out.

## Unresolved Questions and Bikeshedding

* Is the `description` field something that is required by the BOM Standard mentioned in the Paketo BOM RFC? (The field
  mentioned in the RFC is `summary`, which is the same as the description)
    * If this is required, is there a standard way to capture the package description in Go applications and libraries?

## Resources

* [Paketo BOM RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0033-bill-of-materials.md#overall-schema)
* Work in progress [Cloud Native Buildpacks BOM Format RFC](https://github.com/buildpacks/rfcs/pull/166)
