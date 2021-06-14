# Buildpackless Builders

## Summary

Paketo builders are a way of distributing Paketo buildpacks and stacks along
with the CNB lifecycle. Currently, Paketo distributes the Full, Base and Tiny
builders, which include different sets of buildpacks and whose stacks each
have different mixins. While they are a simple way of packaging all the
necessary components for a Paketo build, they often include more than a user
actually needs. This RFC proposes that Paketo publish buildpackless versions of its
three builders. These will include the same build- and run-images as their
standard counterparts, but will include **neither buildpacks nor orders**. This will
speed up builds by reducing the number of unnecessarily-pulled layers, without
forcing Paketo users to maintain their own builders if they want to curate the
buildpacks that are included in a build.

## Motivation

Paketo currently distributes the
[full](github.com/paketo-buildpacks/full-builder),
[base](github.com/paketo-buildpacks/base-builder), and
[tiny](github.com/paketo-buildpacks/tiny-builder) builders. These each include
a set of buildpacks, a build- and run-image, and a version of the CNB
lifecycle. The most recently-released version of the Full Builder (v0.1.130)
contains 106 layers. These include layers for the build- and run-images and
layers for the included buildpacks. If a user builds their app with `pack`
using the Full Builder, all 106 layers of the builder must be pulled onto the
local Docker daemon before the build can begin. As many Paketo users and
maintainers can likely attest, pulling such a large builder can be
time-consuming.

What's more, users rarely need all of the buildpacks published in the builder
for their build. An app dev user likely knows which language family their app
belongs to and can select individual buildpacks accordingly. An operator user
likely knows which subset of buildpacks are needed for the developers they work
with. Thus, for most users, the Paketo builders offer more language family
buildpacks than will be used. Users experience a time cost with no appreciable
benefit. To improve their build times, users might maintain their own builders
that only include the buildpacks they require. Paketo's jam CLI has a `jam
update-builder` command that facilitates keeping a `builder.toml` up to date
with the latest versions, but users must still set up automation to
periodically run the builder update. This is overhead that many users may not
want to take on.

Within Paketo's testing, buildpack test suites frequently use the base builder,
but overwrite the buildpacks included in the builder using the `--buildpack`
option for pack (more specifically, using the corresponding `WithBuildpacks()`
configuration in occam). In this scenario, the entire builder image is pulled
onto the test runner's daemon – and then all of the pulled buildpacks are
promptly ignored. Pulling unnecessary layers slows down Paketo's tests.

This RFC proposes that Paketo publish builders that package up build- and
run-images with the lifecycle but exclude buildpacks and orders. These builders
would be significantly smaller than the existing builders, leading to shorter
builder image pull times.

Since the CNB spec currently [supports including `[[ buildpacks ]]` in a
project file
(`project.toml`)](https://buildpacks.io/docs/reference/config/project-descriptor/),
users can specify the buildpack(s) for their build in an easily stored and
reproducible way. Users can, of course, also specify which buildpacks to
include in the build with the `--buildpack` flag for pack.

The proposed new builders will thus speed up users' builds and Paketo's
buildpack tests while relying only upon the existing functionality that the
pack CLI provides.(No upstream contributions required.)


## Detailed Explanation

### Definitions
- **buildpackless builder** : A
  [builder](https://buildpacks.io/docs/concepts/components/builder/) that
  includes a build-image, a reference to a run-image, and a lifecycle, _but no
  buildpacks nor order groups_.
- **standard builder**: A builder that includes buildpacks and order groups in
  addition to the build-image, lifecycle, and reference to a run-image.

### Calculating Builder Size

To determine the number of layers in a given builder image, one can use the
`docker history` command. Its output shows one line per layer. For example, to
calculate the number of layers in the latest Paketo Full builder, simply run:
```
docker pull paketobuildpacks/builder:full
docker history -q paketobuildpacks/builder:full | wc -l
```

### What will the Paketo Buildpackless Builders look like?
The `buildpackless-builder.toml` for a given Paketo Buildpackless <Name> Builder will be identical
to the corresponding standard Paketo <Name> Builder, but will have the `[[
buildpacks ]]` and `[[ order ]]` sections removed. For instance, the Buildpackless
Full Builder will have a `buildpackless-builder.toml` that looks like:

```
description = "<some description that clearly states buildpacks must be specified with this builder>"

[lifecycle]
  version = "X.Y.Z"

[stack]
  build-image = "docker.io/paketobuildpacks/build:X.Y.Z-full-cnb"
  id = "io.buildpacks.stacks.bionic"
  run-image = "index.docker.io/paketobuildpacks/run:full-cnb"
  run-image-mirrors = ["gcr.io/paketo-buildpacks/run:full-cnb"]
```

The above stated change results in a ~88% decrease in the number of layers
as compared to Paketo Full Builder v0.1.130.

### How will the Paketo Buildpackless Builders be distributed?
Paketo will maintain and publish buildpackless builders that correspond to each
of its three existing standard builders. Their config files
(`buildpackless-builder.toml`) will be checked in to the same repos as the
standard builders (paketo-buildpacks/full-builder, etc.).  They'll be pushed to
Dockerhub and GCR using tags `paketobuildpacks/builder:buildpackless-full` for
the latest builder and `paketobuildpacks/builder:1.2.3-buildpackless-full` for
version 1.2.3 of the builder. This parallels the [current tagging
syntax](https://hub.docker.com/r/paketobuildpacks/builder/tags?page=1&ordering=last_updated)
of `paketobuildpacks/builder:full` and `paketobuildpacks/builder:1.2.3-full`.

The buildpackless builders will be versioned independently from the standard
builders. The versioning of the buildpackless builders will follow the
[Semantic Versioning RFC](https://github.com/paketo-buildpacks/rfcs/pull/49)
guidelines. See [Implementation](#Implementation) for more on how the separate
versioning can be accomplished within a single Github repository.

### How will users interact with Paketo Buildpackless Builders?
Users will be expected to specify buildpacks via command line arguments or
project descriptor files.

For instance, to build [this sample
app](https://github.com/paketo-buildpacks/samples/tree/e51d084f5246f33850220145ae644314350d1989/dotnet-core/runtime),
they'll either set up a `pack build` like:
```
pack build dotnet-with-buildpackless-builder \
           --buildpack gcr.io/paketo-buildpacks/dotnet-core \
           --builder gcr.io/paketo-buildpacks/builder:buildpackless-base
```

or use a `project.toml` that includes:
```toml
[[build.buildpacks]]
uri = "gcr.io/paketo-buildpacks/dotnet-core"
```

And pass the project descriptor to the `pack build` like:
```
pack build dotnet-with-buildpackless-builder \
           --project-file project.toml
           --builder gcr.io/paketo-buildpacks/builder:buildpackless-base
```

In fact, `pack` already supports supplying a `builder` key in a project file as
of pack [v0.18.1](https://github.com/buildpacks/pack/releases/tag/v0.18.1).
This will [soon be in the project descriptor
spec](https://github.com/buildpacks/spec/issues/215) as well. Users can then
set up a project.toml:
```toml
[build]
builder = "gcr.io/paketo-buildpacks/builder:buildpackless-base"

[[build.buildpacks]]
uri = "gcr.io/paketo-buildpacks/dotnet-core"
```

and then run the build:
```
pack build dotnet-with-buildpackless-builder --project-file project.toml
```

### Resource utilization analysis

Builder Image Size comparison (builders created via `pack builder create` pack v0.18.0)
|                               | 0.1.135-full | 0.1.101-base | 0.1.65-tiny |
|-------------------------------|--------------|--------------|-------------|
| Standard                      | 1.41GB       | 663MB        | 413MB       |
| Buildpackless                 | 1.02GB       | 344MB        | 344MB       |
| Buildpackless (% of Standard) | 72%          | 52%          | 83%         |

#### Image pulls

Paketo currently maintains ~100 buildpack repositories across the Paketo
Buildpacks and Paketo Community Github organizations. Of these, approximately
80 run integration tests using the Paketo Base Builder against each opened PR.
Each of these receives a pull request that needs to be tested approximately 4x
per week (this includes dependency-update PRs and feature contributions).

During each test run, approximately 20 seconds is spent pulling the base
builder (excluding the time used to pull the run image).

Therefore, a rough estimation of the Github Actions compute time spent pulling the base builder is:
```
20 seconds/image pull * 1 image pull/PR * 4 PRs/week/repository * 80 repositories = 6400 seconds/week = 1.74 hours/week
```
For each additional repository added to the project, the time spent pulling the
builder increases by:
```
20 seconds/image pull * 1 image pull/PR * 4PRs/week/repository = 80 seconds/week/repository
```

Assuming a constant download speed, the buildpackless builder would use 52% of
that time to pull the buildpackless builder.
```
(20*0.52) seconds/image pull * 1 image pull/PR * 4 PRs/week/repository * 80 repositories = 3328 seconds/week = 0.92 hours/week
```

For each additional repository added to the project, the time spent pulling the
buildpackless builder increases by:
```
(20*0.52) seconds/image pull * 1 image pull/PR * 4PRs/week/repository = ~41.6 seconds/week/repository
```
When considering builder image pulls in test automation alone, it's clear that
a buildpackless base builder would save time when running tests.

#### Image pushes and storage

Publishing a new builder or builders does come with the overhead of building
and pushing additional builder images to Docker Hub and GCR.

Each builder (tiny, base, and full) is pushed to the registries roughly 4 times
per week. If the buildpackless builders are versioned and updated alongside
their standard counterparts, we can therefore expect them to be released 3-4
times per week with those same build image updates.

At first glance, it might seem that pushing the buildpackless builders would
increase the image push overhead of the Paketo project. However,
the buildpackless builders by definition contain a subset of the layers in the
standard builders. Therefore, publishing these builders will never result in
net-new layers being pushed to the registry. The computation cost of pushing a
buildpackless builder is simply the cost of pushing its metadata (i.e. quite
cheap). By the same token, the storage overhead of pushing these builders to
GCR and Docker Hub is also negligible, as the only net-new data stored is metadata.

### Builder updates
The current process of updating the Paketo builders is fully automated, uses
the `jam update-builder` command (which accepts a `builder.toml` as a
parameter), and takes negligible time to run. Updating a second builder config
file in each builder repo therefore has little impact on maintenance cost for
the project.

## Rationale and Alternatives

1. Do nothing. Assume that mature Paketo users will set up their own builders
  and that this doesn't pose too much maintenance burden for them.
   - Benefits:
     - No work required from Paketo project.
   - Drawbacks:
     - All of the pain points described in the Motivation section of this RFC.

1. Publish a Github Action, Concourse task, and other pre-made CI/CD tooling
   templates that use `jam update builder` to keep users' custom builders up to
   date.
   - Benefits:
     - Users can benefit from custom builders with diminished time investment
   - Drawbacks:
     - Paketo isn't a CI/CD tooling-focused project. This would expand the scope
     of released artifacts for which the project is responsible.

1. Make upstream contributions to pack that speed up builder pull times
   - Benefits:
     - Addresses the platform's problem of slow build times more directly. Will
      benefit performance for users with _all_ builders.
   - Drawbacks:
     - Requires upstream contribution that may require an RFC. Optimizing image
    pulls from a registry does not necessarily fall in scope of the Paketo
    project currently. May require Paketo contributors to build up expertise
    that is tangential to Paketo's main aims.

## Implementation

### Configuration files (`buildpackless-builder.toml`)

The configuration files for the buildpackless builders should be checked in to
the repos of each of the existing builders. They can be named
`buildpackless-builder.toml`.

### Repo Automation

In each of the existing builder repositories, steps should be added to the
automations that a) update the builders b) cut releases of the buildpackless
builders and c) push their images to registries. A simple smoke test should be
run against the buildpackless builder to ensure that it is useable in a `pack
build`. The standard builders' smoke tests are sufficient for testing
buildpacks' continued compatibility with the builder.

Since standard and buildpackless builders will be checked into the same repo,
some care must be taken to automate release and image pushing workflows. An
example approach on [this fork of the tiny builder
repo](https://github.com/fg-j/tiny-builder) uses the [Release
Drafter](https://github.com/release-drafter/release-drafter) Github Action to
automate the creation and versioning of releases. In this approach the
`buildpackless-builder.toml` is checked into an orphaned `buildpackless`
branch. See the fork's
[README.md](https://github.com/fg-j/tiny-builder/blob/main/README.md) for more
detailed explanation of how the setup works.

### Publishing

The builders should be pushed to Dockerhub and GCR with tags as follows (using
Buildpackless Full Builder as an example):
- `paketobuildpacks/builder:buildpackless-full` for the latest builder
- `paketobuildpacks/builder:1.2.3-buildpackless-full` for version 1.2.3 of the builder

It is not necessary to push these builders to any tags in the `cloudfoundry` DockerHub org.

### Documentation
The READMEs in the builders' repos, the `description` fields in their
`buildpackless-builder.toml` files and the Paketo website should all clearly
document that these builders cannot be used without buildpacks specified at
run-time.  Documentation should also clearly state how a user can establish
which buildpacks are compatible with which builders (hint: look at the
co-located standard `builder.toml`).
