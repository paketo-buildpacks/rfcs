# Paketo Buildpacks Dependency Packaging

Authors: @dmikusa, @ForestEckhardt

## Summary
This proposal suggests that we should add a new way for buildpacks to manage,
package, and ship dependencies. At this point in time, we are not advocating
for the deprecation or removal of the present way of managing dependencies,
however, we hope over time that will be the natural evolution of things.

## Motivation
Presently, a Paketo buildpack that has binary dependencies will list metadata
about these dependencies within its `buildpack.toml` file. This includes a URL
from which the dependency can be downloaded, and also a checksum hash and other
metadata like PURL and CPEs.

Libraries like `libpak` and `packit` then provide convenience methods for
fetching dependencies using this metadata, verifying the download, and caching
the download result. In addition, they provide tooling to download and store
these dependencies within buildpack images for distribution in offline
environments.

There are also tools published by the project to manage the entries within
`buildpack.toml` through CI pipelines so that dependencies metadata is kept
up-to-date with upstream sources. Unfortunately, this represents a large amount
of toil for the buildpacks team.

As an example of the toil mentioned in a language family like Java, there are
daily project dependencies that need to be updated. This requires reviewing and
merging PRs into the buildpacks to adjust `buildpack.toml` dependency metadata.
Once PRs are merged, a component buildpack needs to be released, followed by a
composite buildpack and then a builder release. This is because most users
don’t consume buildpacks directly, they consume builders which include
buildpacks.

This all has to be done as aggressively as possible so that we are shipping
dependencies, in particular those with security fixes, quickly. This is because
with metadata in `buildpack.toml`, even if an upstream project releases a bug
or security fix, buildpack users cannot get that fix until we update and
release component and composite buildpacks as well as the builder.

There is also toil associated with the tools and pipelines used for this
process. The tools have bugs and need to be updated. At present, the tools we
use to manage all of these updates do not scale well either. In particular
Github Actions, we have had a number of issues hitting rate limits and usage
caps. This gets worse when there are a lot of dependencies to watch, for
example, if your buildpack has multiple version lines or different sets of
packages for a dependency.

The whole process puts an additional maintenance burden on the project
maintainers and project resources. This is not the type of work that a casual
contributor to Paketo will do and as we add more dependencies the burden only
increases on the maintainer teams.

The motivation of this proposal is to…

- Reduce the burden and toil for Paketo buildpack maintainer teams
- Continue publishing dependency updates in a timely and secure manner
- Decouple installing dependencies from configuring them
- Separate metadata and the actual dependencies so they can be provided to
  buildpacks in a number of different and flexible ways
- Establish a reasonable release schedule for buildpacks that’s based around
  development, not dependencies and thus enabling buildpacks to support version
  lines
- Make it easier to package buildpacks for offline environments.

## Detailed Explanation
At a high level:

- We will define a metadata format that includes the metadata fields currently
  present in `buildpack.toml`.
- We will add a dependency version validation section to `buildpack.toml`
  metadata, this can be used to state that a buildpack version only supports
  certain ranges of a given tool, such as Java `11.*` or Node.js `16.*`.
- Metadata can be provided by anyone. A user can add custom metadata, or source
  from a third party project. Paketo will provide an official set of metadata
  against which we will test the Paketo buildpacks. It will be distributed via
  images in an image registry (Docker Hub).
- Buildpacks do not care how dependency metadata is distributed, that is a
  separate concern, instead, they just read metadata from a specified location.
  It is on the platform to mount the metadata that it fetched at that location.
- The actual dependencies are accessed via the metadata and that can happen
  over any protocol (HTTPS/SFTP/FILE) and be distributed in any format
  (archive/image).
- Dependency metadata will be removed from `buildpack.toml`


## Metadata Format
The metadata presented to a buildpack will be structured as a directory of
dependencies.

Like it does now, each dependency will have an id but unlike the present
situation, the id is namespaced. An id is composed of an organization name and
a dependency name. It follows the [reverse domain name notation](https://en.wikipedia.org/wiki/Reverse_domain_name_notation) and the
dependency name is defined as the final item, so `com.example.dep-a` would have
an organization of `com.example` and a dependency of `dep-a`. It is case
insensitive, so `dep-a` is no different than `Dep-A`. This is to reduce the
possibility of [typosquatting](https://en.wikipedia.org/wiki/Typosquatting).
Allowed characters are [the same as for a valid hostname](https://en.wikipedia.org/wiki/Hostname#Syntax).

The directory structure will contain a folder for each dot-separated segment of
the dependency’s organization name and in the lowest level directory there will
be a file named after the dependency name with the extension `toml`, this is
because the metadata file will be TOML format. For example, with
`com.example.dep-a`, there would be the following folder structure:

```
com
└── example
    └── dep-a.toml
```

As mentioned previously, each individual metadata file has a file name
consisting of the dependency name with an extension of `toml`. The internal
format consists of a single table called `versions` which is an array of tables
containing all of the versions for that particular dependency. Each version
entry requires a `uri`, `version`, `checksum`, `arch`, `os`, and `license`. It
may also have `name`, `purl`, `strip-components`, and `cpes` although these are
optional. The `cpes` entry is an array of strings identifying all of the CPEs
for that dependency. The `license` is itself an array of tables containing
`type` and `uri` of the license for the dependency.

For example:
```toml
[[versions]]
cpes = [ "cpe:2.3:a:apache:maven:3.8.6:*:*:*:*:*:*:*" ]
name = "Apache Maven"
purl = "pkg:generic/apache-maven@3.8.6"
checksum = "sha256:c7047a48deb626abf26f71ab3643d296db9b1e67f1faa7d988637deac876b5a9"
arch = "x86_64"
os = "linux"
distro = "ubuntu-18.04"
uri = "https://repo1.maven.org/maven2/org/apache/maven/apache-maven/3.8.6/apache-maven-3.8.6-bin.tar.gz"
version = "3.8.6"
strip-components = 1

  [[versions.licenses]]
  type = "Apache-2.0"
  uri = "https://www.apache.org/licenses/"

[[versions]]
cpes = [ "cpe:2.3:a:apache:mvnd:0.7.1:*:*:*:*:*:*:*" ]
name = "Apache Maven Daemon"
purl = "pkg:generic/apache-mvnd@0.7.1"
chekcsum = "sha256:ac0b276d4d7472d042ddaf3ad46170e5fcb9350981af91af6c5c13e602a07393"
arch = "x86_64"
os = "linux"
uri = "https://github.com/apache/maven-mvnd/releases/download/0.7.1/mvnd-0.7.1-linux-amd64.zip"
version = "0.7.1"

  [[versions.licenses]]
  type = "Apache-2.0"
  uri = "https://www.apache.org/licenses/"
```
## Dependency Validation
In `buildpack.toml` we will add a section to metadata for specifying dependency
validation parameters. This is a way that buildpacks can state that they do or
do not support certain versions of dependencies.

A buildpack does not need to include this section, it is optional. If included,
the buildpack and libraries like `libpak` and `packit` may use the information
to fail if dependency versions are requested by a user that might cause
problems for the buildpack. It is the buildpacks responsibility to process the
validations and react to them, whether that be warning the user or even
failing.

The format for this metadata is such that you have an array of tables called
`validations`. Each table in the array contains the dependency id, which
follows the format of a dependency id as outlined in the [Metadata
Format](#metadata-format) section. In addition, it includes an array of strings
called `supported` which contains a list of [semver](https://semver.org/)
ranges that indicate what is supported by that buildpack. Optionally it can
contain a `type` which defaults to `semver`, but can be set to `regex`.

It is recommended that buildpack authors use semver as the type because
matching is generally simpler that way, however, if a dependency does not
follow semver you may use regular expressions to match the versions that are
compatible with the buildpack.

If any semver range or regular expression matches then it can be assumed that
the buildpack is compatible. If no range matches then it can be assumed that
the version is not compatible.

For example:
```toml
[[metadata.validations]]
dependency-id = "com.example.jre"
supported = [ "8.0.*", "11.0.*", "17.0.*" ]

[[metadata.validations]]
dependency-id = "com.example.nodejs"
supported = [ "^16.0", "^17.0", "^18.0" ]

[[metadata.validations]]
dependency-id = "com.example.tomcat"
supported = [ "8\.5\.\d+", "9\.0\.\d+", "10\.0\.\d+" ]
type = “regex”
```

A buildpack is encouraged to be as permissive as possible. This ensures that a
buildpack author won’t have to frequently update this metadata. This should be
balanced by buildpack authors to provide compatibility guarantees with the
tools required to run the buildpack and for the software it is installing to
run. Generally, we believe that most buildpacks will be compatible with the
major versions of software they presently support and that new major versions
of dependencies should be tested and validations should be expanded after
testing.

## Metadata Distribution
There is no prescribed method for distributing metadata. It could be done in a
variety of ways, including HTTPS/SFTP distributed archives, `rsync` of remote
directories, or even distributed as an image through an image registry.

For the Paketo project, this proposal suggests distributing metadata through
images in an image registry. This allows the project to use the existing image
registry to distribute the metadata. Image registries also have inherent
properties that help with security, like an image cannot be modified without
creating a new hash for the image and images can be signed (signing is out of
scope for this proposal). In addition, images are easily versioned such that
users can hold back updates to dependencies if desired and are easily cached.

The contents of the image will contain the directory structure defined in
[Metadata Format](#metadata-format). There should not be a top-level directory
added, so the root of the image should contain all of the directories created
as top-level organization names, like `com` or `org`. All of the metadata is to
be included in a single layer. Updates to metadata will require downloading the
entire layer again, however, it is a single layer and the size is expected to
be small so this should be very fast.

Further, this proposal suggests subdividing metadata images by project
sub-team. Each sub-team will be given a unique reverse domain name like
`io.paketo.java` and `io.paketo.utilities`. In this way, the project’s metadata
can be easily combined without having conflicts.

This allows users to pick and choose the metadata that’s relevant to their
needs.

## Buildpack Dependency Metadata Interface
The interface between dependency metadata and a buildpack is simple. A single
directory of metadata will be presented to the buildpack. It will be presented
at the location specified by `BP_DEPENDENCY_METADATA`, which defaults to
`/platform/deps/metadata` (the intent is to pilot and try out this or possibly
other locations, eventually proposing an RFC with Cloud-Native buildpacks to
standardize the location).

Buildpacks do not care if there are multiple sources of metadata information,
however, this needs to be merged and presented to the buildpack as one single
directory. How that information is merged is outside of the scope of this
document, but the directory structure defined in [Metadata
Format](#metadata-format) guarantees that there will not be any duplicate
dependency ids.

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

## Dependency Assets
This proposal does not impact how dependencies are being distributed and it
supports the current methods referring to remote locations, like upstream
projects, or using the Deps Server. The dependency metadata just needs to point
to the location from which the dependency should be fetched as is currently
being done with the buildpack.toml dependency metadata.

For builders, buildpacks, or platforms that would like to inject dependency
assets directly into the build container, perhaps to support offline builds, we
propose defining `BP_DEPENDENCY_BINARIES` which defaults to
`/platform/deps/assets` as the location where the actual dependency assets
should be located (again, the intent is to pilot and try out this or possibly
other locations, eventually proposing an RFC with Cloud-Native buildpacks to
standardize the location).

In this way, one could have dependency metadata that uses `file://` URLs to
refer to a stable location, i.e. `/platform/deps/assets/…`. These dependencies
could then be accessed by the buildpack directly, and the buildpack doesn’t
need to care how they were added to the container.

This document does not specify how the dependency asset folder should be
provided to buildpacks but here are some possibilities:

1. External. The dependency assets can be managed outside of the buildpack
   lifecycle. This allows for users to manually pull in the dependency assets
   they would like when they would like them. It also outlives the buildpack
   lifecycle so assets could be shared across builds for greater caching
   benefit. The assets can then be mapped into the build container at the
   specified location using a volume mount to `pack build`.
1. Via builder. The builder could come with assets included under
   `/platform/deps/assets`. This would likely require a builder with many
   buildpacks to update very frequently though, so may not be the best idea for
   the average case, however, it could be very useful as a way to distribute
   dependencies in offline environments.
1. Via the platform. Platforms may choose to offer enhanced functionality to
   more easily distribute dependencies. In the end, the platform just needs to
   ensure that the dependency metadata is available to the buildpack in the
   required location.

## Implementation
### Tools
To start the implementation, we’ll create some tooling to work with the new
metadata format. We’ll create some basic tools for authors to add metadata,
update metadata, and package metadata into compressed archives and images. For
buildpack users, we’ll create some tooling to fetch metadata, overlay metadata
from multiple sources, pre-cache assets from metadata, and feed metadata and
pre-cached assets into `pack build`.

### Library Enhancement
The next step will be to add new functionality in `libpak` and `packit` for
consuming metadata from the defined metadata location and for consuming
dependency assets from this metadata. This can be done in an additive way so
that existing functionality continues to be supported. Support for
`buildpack.toml` dependency metadata can be deprecated and removed on a
separate timeline.

### Update Buildpacks
When we have library support, we’ll be able to update the Paketo buildpacks
that are installing dependencies to use the metadata provided. For example, we
can update the Bellsoft Liberica or Amazon Corretteo buildpacks to install
their JRE/JDK dependencies using this new metadata.

We propose a flag of `BP_EXTERNAL_METADATA_ENABLED` which defaults to `false`
for use as buildpacks are being converted. In the default state, this flag
tells a buildpack to use the metadata included with buildpack.toml. When set to
`true`, a buildpack should use the new metadata. This can provide a way for
users to test the new functionality without impacting existing users.

### Write Documentation
Documentation will be added at each step. Initial tool documentation will be on
the repositories for the tools. The `libpak` and `packit` libraries will update
their docs as support is added. As individual buildpacks are updated, the
`README.md` for each buildpack will be updated with the newly supported
options. When an entire language family is complete, the information will be
merged into the official Paketo documentation.

### Buildpack Migration Process
Once a language family has added support for the new metadata format and
documentation has been updated, the language family may begin the deprecation
process. This proposal does not dictate how that process should be done, but
provides some recommendations. The language family team ultimately has
discretion on how to proceed.

The recommendation of this proposal is to announce the change in the release
notes and on Slack, providing links to documentation of the new feature. The
goal of this migration is that there is no loss of functionality for buildpack
users, so we do not need to trigger a major release and we can remove the older
functionality and buildpack.toml entries as is convenient for buildpack teams.

There is some risk in removing buildpack.toml entries. We have not documented
the format of the dependency information but the format has been consistent for
the current lifetime of the buildpacks and it is possible users may have tools
or integrations to read it. Teams may want to continue maintaining both sets of
metadata for a period of time, however, this will increase cost and maintenance
burden so teams may want to survey users regarding the impact. Language family
teams are free to make a decision best for their users and team.

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
- [Investigation proof-of-concept](https://github.com/paketo-community/explorations/tree/decoupled-dependencies/decouple-dependencies)

## Unresolved Questions and Bikeshedding
- Which method of delivery should be used for the dependencies metadata?
