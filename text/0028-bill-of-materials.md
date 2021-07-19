# Implement a Bill of Materials Across Paketo

## Summary

A bill of materials (BOM) is a set of metadata that provides an account of the
dependencies and tools that are both present in an application image, as well
those used in the construction of that image. The availability of this data is
a key value proposition of Cloud Native Buildpacks.

As an implementation of Cloud Native Buildpacks, the Paketo project should
support adding bill of materials metadata across the different components that
go into an app image. This RFC serves as an intent to implement the BOM and
defines the minimal set of key/values to be included.

## Motivation

A BOM can include an array of different metadata about application dependencies
and buildpack dependencies such as SHAs, URIs, versions, license information,
vulnerability identifiers, etc. This information is valuable for users who want
an accurate inventory of everything in their final application image, or that
may have been used to build it. Having access to that information makes it
easier to audit for vulnerabilities and license information.

The Paketo Java Buildpacks as well as a handful of other Paketo Buildpacks
already make the BOM available. Another motivation for doing this work is to
achieve a consistent user experience across the Paketo project.

## Detailed Explanation

The following Paketo components should have BOM metadata attached to them:

### Overall Schema
The bill of materials for each of type of entry should have some subset of
fields that conform to the overall schema below.
```
[[bom]]
name = "<dependency name>"

[bom.metadata]
  version = "<dependency version>"
  sha256 = "<hash of dependency artifact from uri>"
  uri = "<uri to dependency>"
  arch = "<compatible architecture>"
  summary = "<package summary>"
  cpe = "<version-specific common platfrom enumeration>"
  purl = "<package URL>"
  licenses = [<licenses that the dependency has>]

[bom.metadata.source]
  name = "<dependency source name>"
  version = "<dependency source version>",
  uri = "<uri to the dependency source>"
  sha256 = "<hash of the dependency source artifact from source-uri>"
  upstream-version = "<dependency source upstream version>"
```

### Stacks
Stacks (such as those found in the [Paketo Stacks
repository](https://github.com/paketo-buildpacks/stacks)) should have BOM
metadata that includes in-depth information on all of the OS level packages
installed as part of the stack.

The minimal set of keys to include in these type of BOM entries are:
```
[[bom]]
name = "<dependency name>"

[bom.metadata]
  version = "<dependency version>"

[bom.metadata.source]
  name = "<dependency source name>"
  version = "<dependency source version>",
  upstream-version = "<dependency source upstream version>"
```
The optional set of keys may include:
```
# Optional parameters
[bom.metadata]
  arch = "<compatible architecture>"
  summary = "<package summary>"
```
This closely resembles the content of the metadata that is already available on
stacks.

### Directly Installed Dependencies
Dependencies that directly provide runtimes and/or are tools used for
compilation should have BOM metadata surfaced about them. This includes both
the dependencies in the final application image, as well as those used during
the image building process. An example of this type of dependency is the
node-engine dependency that is provided by the [Paketo Node Engine
Buildpack](https://github.com/paketo-buildpacks/node-engine). These are the
type dependencies that are usually listed in the
[`buildpack.toml` file](https://github.com/paketo-buildpacks/node-engine/blob/main/buildpack.toml).

The minimal set of keys to include in these type of BOM entries are:
```
[[bom]]
name = "<dependency name>"

[bom.metadata]
  sha256 = "<hash of dependency artifact from uri>"
  uri = "<uri to dependency>"
  version = "<dependency version>"
```
The optional set of keys may include:
```
  # Optional parameters
[bom.metadata]
  cpe = "<version-specific common platfrom enumeration>"
  purl = "<package URL>"
  licenses = [<licenses that the dependency has>]

[bom.metadata.source]
  uri = "<uri to the dependency source>"
  sha256 = "<hash of the dependency source artifact from source-uri>"
```

### Indirectly Installed Dependencies
The final component that we should aim to publish BOM metadata for is for
dependencies that are indirectly installed. These types of dependencies are
either downloaded during the image building process or vendored as part of the
application. If Angular was installed as a module by the [Paketo NPM Install
Buildpack](https://github.com/paketo-buildpacks/npm-install), it would fall
under this category as something we'd want to provide BOM metadata for.

The BOM entries for this category should also include information about the
modules available in the final image, as well as those used to construct the
image.

The minimal set of keys to include in package module BOM entries are:
```
[[bom]]
name = "<module name>"

[bom.metadata]
  version = "<module version>"
```
Note that this should have the same structure as the runtime and compilation
dependency BOM entries. Some fields (such as `uri` , for example) have been
omitted until further investigation is done to find out how these can be
obtained. The final set of fields will be some subset of the fields available
on our Directly Installed Dependencies.

### License Information

As a note, the plan is to use various scanning tools in order to obtain license
information for all dependencies. It should be assumed that you are receiving
all of the output from a given license scanning tool with no further vetting at
this time. If this could potentially cause issues for your compliance process
you should go through with any advanced compliance that is normally required.
However, there should be a good faith effort to provide only false-postive
license results to ensure that individuals can still trust that all relevant
licenses are present. This level of confidence and verification may change in
the future, but that change should be communicated in later documentation.

### Package URLs

[Package URLs](https://github.com/package-url/purl-spec) will be provided for
our directly installed dependencies. These types of dependencies (runtime
dependencies) do not have explicitly supported types in the [Package URL
Types](https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst)
document, so we will use the `generic` or `debian` types as instructed by
maintainers of the Package URL project. For indirectly installed dependencies,
there are specific types we can use for most of the languages we support (Go
modules, NPM packages, etc.)
