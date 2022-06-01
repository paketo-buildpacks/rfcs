# Dependency Management Phase 1: Adopting Federated Model RFC

## Proposal

The buildpacks should adopt a federated dependency management strategy. This
will involve all of the buildpacks that provide depdendencies (such as the [Go
Dist CNB](https://github.com/paketo-buildpacks/go-dist) or the [MRI
CNB](https://github.com/paketo-buildpacks/mri)) becoming the owners of
dependency-specific logic that currently resides in the
[dep-server](https://github.com/paketo-buildpacks/dep-server). This includes
code for discovering new versions, retrieving dependencies, and compiling the
dependencies. As a result, maintainers will make/maintain dependency-related
decisions for the dependencies of relevant buildpacks.
Additionally, buildpacks should use dependencies directly from upstream hosting (source or binary) whenever
possible, to cut down on the number of dependencies that are uncessarily
compiled from source.

## Motivation

Per top-level [RFC
0000](https://github.com/paketo-buildpacks/rfcs/blob/dependency-management-top-level/text/dependencies/rfcs/0000-dependency-management-overview.md),
the current dependency management system employed
in the project leads to a number of painpoints, predominantly around
maintainability for Dependencies maintainers, and lack of extensibility by
compiling dependencies for Ubuntu 18.04. In order to ensure the Paketo
Buildpacks project can continue to grow and introduce new buildpacks,
dependencies, and stacks, business logic that pertains to specific dependencies
should be the responsibility of the relevant buildpack.

## Detailed Explanation

The outlined proposal contains a number of changes to the current system which
should be standardized in order to fit together with generalized Github Actions
workflows down the line.

### Background
Dependency-specific logic lives in a few different places today:
- Version discovery code comes from [dep-server/pkg/dependency](https://github.com/paketo-buildpacks/dep-server/tree/main/pkg/dependency)
- Source URI to pull dependency source comes from [dep-server/pkg/dependency](https://github.com/paketo-buildpacks/dep-server/tree/main/pkg/dependency)
- Compilation code comes from
  [cloudfoundry/buildpacks-ci](https://github.com/cloudfoundry/buildpacks-ci/blob/master/tasks/build-binary-new/builder.rb)
  and
  [cloudfoundry/binary-builder](https://github.com/cloudfoundry/binary-builder/tree/main/recipe).
- Workflows to run all aspects of dependency retrieval, compilation, uploading
  to buckets all occur in the [dep-server Github
  Actions](https://github.com/paketo-buildpacks/dep-server/actions)
- Known versions of the dependency come from a JSON file inside of a GCP Bucket

All of these components come together outside of the buildpack within
dep-server automation, and then the dependencies themselves are updated inside
of the buildpacks by a separate [Update Dependencies
workflow](https://github.com/paketo-buildpacks/github-config/blob/main/implementation/.github/workflows/update-dependencies.yml),
which bumps versions in the `buildpack.toml` of a buildpack when a new version
has come out.

### Issues to Address
The main issues addressed by this RFC are related to maintainability,
dependency compilation, and code usability.

1. **Maintainability**. Buildpacks maintainers cannot easily fix issues with
   dependencies if they are wrongly compiled or corrupt, since the code is
   under the jurisdiction of the Dependencies team and mostly runs in
   automation. The relevant automation cannot be run in Github Actions for
   debugging unless a user is a Dependencies contributor, which is an added
   blocker. Additionally, compilation code lives in a separate organization
   entirely, and is written in Ruby, despite the rest of the project being
   written in Golang. It's very difficult for outside contributors to
   contribute to dependency code or make fixes with the current set up. It's
   also challenging for general Dependencies maintainers to make
   language-specific choices about dependencies.

2. **Compilation**. Almost every dependency is compiled from source, or has
   some kind of processing for simple installation in the buildpack build
   process. Dependencies are compiled against Ubuntu 18.04 which means the
   dependencies are not necessarily compatible with other Stacks. This means
   the related buildpacks are locked to running on Ubuntu 18.04 based stacks
   only. Since dependencies are compiled, they are stored in an S3 bucket which
   is costly for an ever-expanding set of dependencies and versions.

3. **Usability**. The current system is difficult to run outside of our
   automation, especially the dependency compilation code. When compilation
   code has to change for a new dependency version, it's very challenging to
   use the code locally to test changes. Similarly, the workflows that run in
   the dep-server are not intuitve to use locally. All of the dependency
   management process should ideally able to run locally with ease, in the
   event of Github Actions outages.

### Dependencies Directly From Upstream
When possible, dependencies should be used directly from their upstream source,
rather than undergoing any additional compilation or modifications performed by
Paketo-maintained code.  For each dependency, the corresponding buildpack
maintainer group will decide if the dependency can be used diretly from
upstream, and must identify the location from which the dependency will be
pulled from.

Some of the Paketo Java buildpacks perform directory stripping during the
buildpack build process itself. This could be a viable alternative to
performing directory modifications during the dependency management process for
maintainers to consider.

All decisions within in a language family should be documented in an RFC.
Rationale should be given for dependencies that we would like to continue
compiling or processing. Maintainers should also consider the ramifications of
their decision in the ability to support "offline" buildpacks that have the
dependency vendored in, if that's a use case supported by the buildpack.

Below are the lists of dependencies the dep-server currently supports, the
source URI, if it is compiled or processed in any way, and where in the code
this behaviour lives now.

<details>
<summary>Dependency list:</summary>

| Name              | Source                                                    | Compiled? And where to find  related code|
| ----------------- | --------------------------------------------------------- | ---------------------------------------- |
| bundler           | https://rubygems.org/downloads/                           | yes, binary-builder                      |
| composer          | https://getcomposer.org/download                          | no, buildpacks-ci                        |
| curl              | https://curl.se/download                                  | yes, buildpacks-ci                       |
| dotnet-aspnetcore | https://download.visualstudio.microsoft.com/download/pr   | processed, buildpacks-ci                 |
| dotnet-runtime    | https://download.visualstudio.microsoft.com/download/pr   | processed, buildpacks-ci                 |
| dotnet-sdk        | https://download.visualstudio.microsoft.com/download/pr   | processed, buildpacks-ci                 |
| go                | https://dl.google.com/go/                                 | yes, binary-builder                      |
| httpd             | http://archive.apache.org/dist/httpd                      | yes, binary-builder                      |
| icu               | https://github.com/unicode-org/icu/releases/download/     | yes, buildpacks-ci                       |
| nginx             | http://nginx.org/download/                                | yes, both locations?                     |
| node              | https://nodejs.org/dist/                                  | yes, binary-builder                      |
| php               | https://www.php.net/distributions/                        | yes, binary-builder                      |
| pip               | https://files.pythonhosted.org/packages                   | yes, with other pip deps buildpacks-ci   |
| pipenv            | https://files.pythonhosted.org/packages                   | yes, with other pip deps buildpacks-ci   |
| python            | https://www.python.org/ftp/python                         | yes, buildpacks-ci                       |
| poetry            | https://files.pythonhosted.org/packages                   | processed, buildpacks-ci                 |
| ruby              | https://cache.ruby-lang.org/pub/ruby                      | yes, binary-builder                      |
| rust              | https://static.rust-lang.org/dist/                        | yes, buildpacks-ci                       |
| tini              | https://github.com/krallin/tini/tarball                   | yes, buildpacks-ci                       |
| yarn              | https://github.com/yarnpkg/yarn/releases/download/v1.15.2 | processed, buildpacks-ci                 |
</details>

### Transfer Compilation Code

For any dependencies that must still be compiled or processed in some way, the
code from the Cloud Foundry repositories should be rewritten,
and moved over to the buildpack under a directory called
`dependency/compilation`. The code should be easily runnable from a local
machine to compile the code, and should be documented with a README about how
to use it. The dependency will likely need to be compiled against different
stacks/architectures, so this should also be enumerated in the RFC and taken
account of in the new compilation code.

The code will eventually be used in a Github Actions workflow, so the location
needs to be standardized across buildpacks. The workflows and Github Actions to
use this code will be enumerated in a separate RFC.

### Bucket Setup

For dependency metadata and the dependencies that must be compiled, there
should be a dependency-specific bucket set up in Paketo Dependencies project
within GCP to store data. The directory name will be the name of the dependency
and it will contain both dependency archives (if compiled), and metadata JSON
file named `metadata.json`. Credentials will be shared between the dep-server,
the buildpack, and buildpack maintainers. As a result, the dep-server will need
to know about all N number of buckets for every dependency once set up.

<details>
<summary>Metadata will be stored the same way it is in the dep-server now, inside of a JSON file:</summary>

```
[
  {
    "name": <dependency name>,
    "version": <dependency version>,
    "sha256":"<dependency SHA256>,
    "uri": <dependency URI>,
    "stacks": [
      {
        "id": <compatible stack ID>
      }
    ],
    "source": <dependency source URI>,
    "source_sha256": <dependency source SHA256>,
    "deprecation_date": <deprecation date>,
    "created_at": <date dependency was created, if compiled>,
    "modified_at": <date depdendency was modified at if modified,
    "cpe": <common platform enumeration>,
    "purl": <package URL>,
    "licenses": [<dependency licenses>]
  },
  ...
  ]

```
</details>

### Store Known Versions

Known versions of each dependency are currently stored in a JSON file in the
same GCP bucket and underlying directory mentioned in the section above. It's
used to keep track of versions we've seen before or don't want to pick up in
the dep-server. To avoid storing frequently updated stateful information in the
Github repository itself, it should be stored in the new dependency GCP bucket
as well, named `known-versions.json`.

### Transfer Version Retrieval Code

Version discovery code comes from
[dep-server/pkg/dependency](https://github.com/paketo-buildpacks/dep-server/tree/main/pkg/dependency).
Each dependency has a slightly different way new versions are made
discoverable. This code should be ported from the dep-server repository to the
buildpack under a directory named `dependency/retrieval`. It should be
well-documented and useable on a local environment. The location must be
standardized for use in automation.


### Transfer Metadata Generation Code
Metadata generation code also comes from
[dep-server/pkg/dependency](https://github.com/paketo-buildpacks/dep-server/tree/main/pkg/dependency).
Code to generate/gather all of the metadata for a dependency should be moved
into the buildpack under the `dependency/metadata` directory.  The
code should do essentially the same thing that the existent code does, and
support the same fields.

The code for getting the  `version`, `URI`, `SHA256`, `ReleaseDate`,
`DeprecationDate`, and `CPE` fields are all dependency-specific and can live in
the buildpack `dependency/metadata` location.

The `PURL` and `licenses` fields are more generic across dependencies, so the
code for generating them should come from a common location, and used as
library in the dependency-specific metadata code to reduce code duplication.
The dep-server repository will retain this code, which can be imported as a
libray in the dependency-specific metadata code can use it as a library.

### Smoke Test
In the dep-server, a smoke test is run against every dependency before the
metadata is uploaded during the Github Actions process. A similar dependency
smoke test should be added to the buildpack that will eventually be used in the
dependency workflows. It should reside inside the buildpack in a directory
called `/dependency/test` so that workflows can locate the test.

### Enable Future Support of Multiple Stacks

Currently, the dep-server contains [a
file](https://github.com/paketo-buildpacks/dep-server/blob/main/.github/data/dependencies.yml)
that lays out what stacks each dependency is compatible with. For each
dependency, a similar `dependency.json` file should be created in the
buildpack at the path `dependency/dependency.json`. This file structure is
enumerated in the "Dependency Configurations File" section below. This will be
useful in the future as buildpacks support more stacks that we will need to
supply compatible dependencies for.

The dependency metadata published will contain a `stacks` field with compatible
stacks, which end up in the `buildpack.toml`. When used in
the buildpack, the right dependency is selected depending on the stack that's
being used for the build. 

### Dependency Configurations File

In each buildpack, a JSON file similar to the dep-server workflow
[dependencies.yml](https://github.com/paketo-buildpacks/dep-server/blob/main/.github/data/dependencies.yml)
file will be added. The content of this file will be used in the code for
dependency/metadata retrieval, as well as in workflows that will run.
Since this file will be used in automation, the format and location should be
standardized across the project.

The file will contain dependency-specific choices the maintainers have made,
such as whether the dependency will be compiled by us or pulled/used directly
from the upstream source, and the upstream source URI of the dependency.

In cases where maintainers have opted to compile dependencies themselves, they
will need to specify the image to compile the dependency against with the
`compile-against` field. In this case, the list of stacks that the dependency will be
compatible with when compiled should be provided, as well as the URI where the
compilation code will pull the source code from.

If the dependency is going to be used from upstream
directly, the `compile-against` field is set to `use-upstream`. There can be
multiple source URIs, which are associated with compatible stacks. This would
come in handy if different source dependencies are needed depending on the
operating system.

```
[
  {
    "name": "<dependency-name>",
    "variants": [
      {
        "compile-against": "<'use-upstream' or the image to build the dependency against>",
        "uri": "<source-uri>",
        "compatible-stacks": [
          "<all compatible stacks>"
        ]
      }
    ]
  }
]
```

<details>
<summary> Example 1: in the Golang case, if maintainers opt to compile the dependency
ourselves from source, and there are AMD64 and ARM64 variants for Bionic-based
and Jammy-based stacks the `dependency.json` file might look like:</summary>

```
[
  {
    "name": "go",
    "variants": [
      {
        "compile-against": "paketobuildpacks/build-bionic-full:latest",
        "uri": "https://go.dev/dl/go<version>.src.tar.gz",
        "compatible-stacks": [
          "io.buildpacks.stacks.bionic",
          "io.paketo.stacks.tiny"
        ]
      },
      {
        "compile-against": "paketobuildpacks/build-jammy-full:latest",
        "uri": "https://go.dev/dl/go<version>.src.tar.gz",
        "compatible-stacks": [
          "io.buildpacks.stacks.jammy",
          "io.buildpacks.stacks.jammy.tiny"
        ]
      },
      {
        "compile-against": "<some Bionic ARM64 build image>",
        "uri": "https://go.dev/dl/go<version>.src.tar.gz",
        "compatible-stacks": [
          "<some Bionic ARM64 stack ID>"
        ]
      },
      {
        "compile-against": "<some Jammy ARM64 build image>",
        "uri": "https://go.dev/dl/go<version>.src.tar.gz",
        "compatible-stacks": [
          "<some Jammy ARM64 stack ID>"
        ]
      }
    ]
  }
]
```
</details>

This example shows the expanding complexity of compiling dependencies ourselves
when multiple OS and architecture combinations are supported.

<details>
<summary> Example 2: Conversely, in the same Golang case, if the dependency is used
directly from its upstream URI, and there are AMD64 and ARM64 variants for
Bionic-based and Jammy-based stacks the `dependency.json` file might look like:</summary>

```
[
  {
    "name": "go",
    "variants": [
      {
        "compile-against": "use-upstream",
        "uri": "https://go.dev/dl/go%s.linux-amd64.tar.gz",
        "compatible-stacks": [
          "io.buildpacks.stacks.bionic",
          "io.paketo.stacks.tiny",
          "io.buildpacks.stacks.jammy",
          "io.buildpacks.stacks.jammy.tiny"
        ]
      },
      {
        "compile-against": "use-upstream",
        "uri": "https://go.dev/dl/go%s.linux-arm64.tar.gz",
        "compatible-stacks": [
          "<some Bionic ARM64 stack ID>",
          "<some Jammy ARM64 stack ID>"
        ]
      }
    ]
  }
]
```
</details>
This example shows the reduced complexity of using the dependency directly from
upstream.

### New Buildpack Directory Contents

In sum, relevant buildpacks will have the following directory and file
additions:
```
buildpack
└───dependency/
│   │   dependency.json
│   └───compilation/
│   │   │   *.go
│   │   │   ...
│   └───retrieval/
│   │   │   *.go
│   │   │   ...
│   └───metadata/
│   │   │   *.go
│   │   │   ...
│   └───test/
│       │   *.go
```

### Rationale and Alternatives
The main rationale for these changes is ease of contribution, ease of
maintenance, and ease of use. Contribution is easier when the code is grouped
in a logical way, which is acheived by locating dependency-specific code
alongside the buildpack it's used in. Maintenance is easier when codeowners are
the people with the most context on the use cases within the buildpack. Many of
the key pieces of code will still exist, just in a different location, like
metadata collection code and version retrieval code with the caveat that
they're well documented and easy to use outside of our automation. It will be
the job of workflows and Github Actions, maintained by the Dependencies team,
to bring the code together to run in an automated and uniform way. The details
of the automation will be outlined in a subsequent RFC.

An alternative to this proposal would be to make the same changes as outlined,
but to move them into a separate dependency-specific repository, rather than
adding all of this into the buildpack. The benefit of this approach would be
that the buildpack code base stays simple and focused, and the dependency code
is still under the maintenance of buildpack teams.

Another alternative is to leave all of the code where it is in the dep-server
(except the compilation code which will still need to be brought into the
Paketo organization). Then, language maintainers will be codeowners of certain
codepaths within the repository. This has the significant drawback that the
codebase and related automation will still have to significantly change in
order to support more stacks/architectures. The scope of the dep-server
repository is already large, as it accounts for every dependency in the
project, potentially making it hard to contribute and maintain.

## Unresolved Questions and Bikeshedding (Optional)
- How will this need to change if the CNB concept of stacks is removed?
- Is there a better way to represent the content of `dependency.json`,
  especially around communicating the seam between stack availabilty and which
  dependency source URI is used.
- Would a separate repository be better than having all of this in one
  buildpack?
- Who is going to pay for the GCP buckets?
