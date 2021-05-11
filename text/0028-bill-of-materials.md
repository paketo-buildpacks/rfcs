# Implement a Bill of Materials Across Paketo

## Summary

A bill of materials (BOM) is a set of metadata that provides an account of the
dependencies and tools that are both present in an application image, as well
those used in the construction of that image. The availability of this data is
a key value proposition of Cloud Native Buildpacks.

As an implementation of Cloud Native Buildpacks, the Paketo project should
support adding bill of materials metadata across the different components that
go into an app image.

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

### Stacks
Stacks (such as those found in the [Paketo Stacks repository](https://github.com/paketo-buildpacks/stacks))
should have BOM metadata that includes in-depth information on all of the OS
level packages installed as part of the stack.

### Runtime and Compilation Dependencies
Dependencies that provide runtimes and/or are used for compilation should have
BOM metadata surfaced about them. This includes both the dependencies in the
final application image, as well as those used during the image building
process. An example of this type of dependency is the node-engine dependency
that is provided by the [Paketo Node Engine Buildpack](https://github.com/paketo-buildpacks/node-engine).

### Language Specific Modules
The final component that we should aim to publish BOM metadata for is language
specific modules that are either downloaded during the image building process
or vendored as part of the application. This too should include information
about the modules available in the final image, as well as those used to
construct the image. An example of a module would be if Angular was installed
as a module by the [Paketo NPM Install Buildpack](https://github.com/paketo-buildpacks/npm-install).
