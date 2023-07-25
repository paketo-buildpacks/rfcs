# Paketo Buildpacks Dependency Packaging

Authors: @dmikusa, @ForestEckhardt, @loewenstein

## Summary
When it comes to binary dependencies, there is currently a strong coupling of the different aspects. This proposal suggests to decouple how buildpacks manage,
package, and ship dependencies from how they install and configure them.
Note that at this point in time, we are not advocating
for the deprecation or removal of the present way of managing dependencies,
however, we hope over time that will be the natural evolution of things.

## Motivation
The key drawback of the current state with dependencies being packaged with the buildpacks is the rapid release cycle this enforces onto individual buildpacks. What makes matters worse is that the release of a buildpack needs to trigger a cascade of releases to include the buidpack in the language family composite buildpack and the builders Paketo offers.
The main motiviation for this proposal is hence that we can establish a reasonable release schedule for buildpacks while keeping the speed of delivering updates of dependencies.
This will significantly reduce the toil for both maintainers and infrastructure and additionally open new possibilities for buildpack providers, platform providers and user organizations to customize the delivery of dependencies.
- buildpack providers might want to provide offline capabilities (for airgapped environments)
- platform providers might offer mirrors for dependencies
- users might control the pace of adopting dependency updates

## Detailed Explanation
At a high level:
- We will define `buildpack.toml` metadata that allows buildpacks to express dependencies by name and version
E.g. "We need a Java Virtual Machine in version 11.\*" or "We need a Node.js runtime in version 16.\*"
- We will define a metadata format that includes the metadata fields currently
  present in `buildpack.toml` and that allows to specify dependencies by name and version.
- We will define a way to discover metadata at build time, that allows anyone to provide it
- We will adapt our tools and processes to provide dependency metadata according to the new formats

How this will be done should be based on the outcome of explorations and will need further RFCs to pin down once we know more.
As dependencies escape the local scope of individual buildpacks, we will need to make sure to disambiguate dependency names. One possibility that has precendent in our industry is the use of [reverse domain name notation](https://en.wikipedia.org/wiki/Reverse_domain_name_notation) for namespacing and restricting the character set to [valid hostname](https://en.wikipedia.org/wiki/Hostname#Syntax) to prevent [typosquatting](https://en.wikipedia.org/wiki/Typosquatting).
There is a similar precendent in the industry for version matching following [semver](https://semver.org/). However, we know already that some dependencies do not follow semver, so a potential fallback to regex or some kind of free form version matching is very likely.

## Metadata Format
We propose that the actual dependency metadata should not be changed.

Each entry requires a `uri`, `version`, `checksum`, `arch`, `os`, and `license`. It
may also have `name`, `purl`, `strip-components`, and `cpes` although these are
optional. The `cpes` entry is an array of strings identifying all of the CPEs
for that dependency. The `license` is itself an array of tables containing
`type` and `uri` of the license for the dependency.

**Note**: We might consider already adding additional metadata - `arch` and `os` - that will come with the adoption of the Cloud Native Buildpack specification changes about stacks & mixins (and remove the soon obsolete `stacks`).

## Buildpack Dependencies
Instead of buildpacks carring the dependency metadata (and assets) themselves, we propose that buildpacks express their dependencies by fully qualified name and version constraints.

Instead of e.g. the Maven buildpack coming with the following dependency metadata in the `buildpack.toml`,

```toml
[[metadata.dependencies]]
  cpes = ["cpe:2.3:a:apache:maven:3.8.6:*:*:*:*:*:*:*"]
  id = "maven"
  name = "Apache Maven"
  purl = "pkg:generic/apache-maven@3.8.6"
  sha256 = "e1e13ac0c42f3b64d900c57ffc652ecef682b8255d7d354efbbb4f62519da4f1"
  stacks = ["io.buildpacks.stacks.bionic", "io.paketo.stacks.tiny", "*"]
  uri = "https://repo1.maven.org/maven2/org/apache/maven/apache-maven/3.9.3/apache-maven-3.9.3-bin.tar.gz"
  version = "3.9.3"

  [[metadata.dependencies.licenses]]
    type = "Apache-2.0"
    uri = "https://www.apache.org/licenses/"
```

it would have the following.

```toml
[[metadata.dependencies]]
  id = "org.apache.maven"
  versions = ["3.*"]
```

**Note**: We will also need a variant with regex support. This could for example look like:
```toml
[[metadata.dependencies]]
  id = "org.apache.maven"
  versions = ["3\.\d+\.\d+"]
```

Buildpack authors are encouraged to be as permissive as possible. This ensures that they won’t have to frequently update this metadata. This should be
balanced by buildpack authors to provide compatibility guarantees with the
tools required to run the buildpack and for the software it is installing to
run. Generally, we believe that most buildpacks will be compatible with the
major versions of software they presently support and that new major versions
of dependencies should be tested and validations should be expanded after
testing.

## Buildpack Dependency Metadata Interface

We propose to figure out how exactly a buildpack will be presented with dependency metadata as part of exploration work and will add a separate RFC once we have figured out a format matching all use cases.
It is clear that however this will look like, buildpacks will need a way to look up dependency metadata based on a fully qualified name and a version.

We will explore ways to distribute dependency metadata (and assets) and provide them to buildpacks for dependency lookup (abstracted via the `libpak` and `packit` buildpack libraries).

This mechanism should support multiple sources of dependencies. The need to provide dependencies in an unambiguous way will likely require precedence rules across those sources.

This document does not specify how the dependency metadata folder should be
provided to buildpacks but here are some possibilities:

1. External. The metadata information can be managed outside of the buildpack
   lifecycle. This allows for users to manually pull in the metadata they would
   like when they would like it. The metadata can then be mapped into the build
   container at the specified location using a volume mount to `pack build`.
1. Via buildpack. We could add a Paketo buildpack to the beginning of buildpack
   order groups that is responsible for pulling metadata and overrides
   `BP_DEPENDENCY_METADATA` to point to its layer. The buildpack can check for
   dependency metadata updates when it runs.
1. Via builder. The builder could come with metadata included under
   `/platform/deps/metadata`. This would likely require a builder with many
   buildpacks to update very frequently though, so may not be the best idea for
   the average case, however, it could be very useful as a way to distribute
   dependencies in offline environments.
1. Via the platform. Platforms may choose to offer enhanced functionality to
   more easily distribute dependencies. In the end, the platform just needs to
   ensure that the dependency metadata is available to the buildpack in the
   required location.

In addition to the flexibility of where the dependencies originate, this
proposal also provides flexibility in how those dependencies are managed such
as floating them so the latest versions are always available, pinning to a
specific set of dependencies or even pinning and including the dependencies
with the metadata.

### Dependency Assets
This proposal does not impact how dependencies are being distributed and it
supports the current methods referring to remote locations, like upstream
projects, or using the Deps Server. The dependency metadata just needs to point
to the location from which the dependency should be fetched as is currently
being done with the buildpack.toml dependency metadata.

For builders, buildpacks, or platforms that would like to inject dependency
assets directly into the build container, perhaps to support offline builds, we
propose to add the assets next to the metadata to allow local references to be used in the metadata.

## Exploration
As a first step, we propose to pick two concrete dependency providing buildpacks (to cover both `libpak` and `packit`) and externalise dependency metadata and assets in a spike.

Once we have figured out some of the details of managing and distributing dependency metadata (and assets), we'll likely augment this RFC or create additional RFCs with more details.

In the end we will need to
- implement lookup in `libpak` and `packit`
- provide tools that can create dependency bundles with metadata (and assets)
- update the buildpacks one-by-one to support/use the new mechanism
- document the new user-facing capabilities like user provided dependency metadata (and assets)

## Rationale and Alternatives
This proposal is to move dependencies outside of the buildpack. The primary
alternative would be to do nothing and keep dependencies inside the buildpack.
The reasons against this are listed in the [Motivation](#motivation) section
above.

It may be possible to have a hybrid approach where there is some part of the
metadata that remains inside of the buildpack, but this is unlikely to help
with the maintenance burden and it would not be as flexible.

Aside from that, there are many variations on the above proposal that could be
taken, but they are not listed as alternatives because they are not complete
alternatives. To discuss variations on the process, like format or location of
metadata, please comment on the proposal instead.

## Prior Art
- There are many package management systems like `apt` and
  [`yum`](https://stackoverflow.com/questions/54470463/is-there-a-specification-for-the-yum-metadata)
  that have repository formats that utilize external configuration. Application
  package managers also have metadata, like Maven has `maven-metadata.xml` and
  `pom.xml` metadata. This proposal follows the metadata style of Maven more,
  as metadata is split across multiple files instead of having central files
  with metadata across the whole repository.
- [Investigation proof-of-concept](https://github.com/paketo-community/explorations/tree/main/decouple-dependencies)

## Unresolved Questions and Bikeshedding
- Which method of delivery should be used for the dependencies metadata?
