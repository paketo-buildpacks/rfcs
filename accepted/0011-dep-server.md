# Dep Server to provide buildpack dependency metadata

## Summary

Dependencies for a buildpack are specified in the `metadata.dependencies` section of the `buildpack.toml`. Those dependencies currently get updated via pull requests from an [open-source](https://github.com/cloudfoundry/buildpacks-ci/blob/master/pipelines/dependency-builds.yml.erb) Concourse [pipeline](https://buildpacks.ci.cf-app.com/teams/main/pipelines/dependency-builds). This RFC proposes creating a hosted server (the Dep Server) that can be queried to retrieve metadata for dependencies, allowing buildpack authors to update their own dependencies.

## Motivation

By hosting a server to provide dependency metadata (and therefore enabling a pull model), buildpack authors can keep the dependencies of their choice up-to-date in whatever manner they desire.

The current model of pushing new dependencies into buildpacks has a few issues:

* Buildpacks that want automatic dependency updates must be specified in the [dependency-builds pipeline configuration](https://github.com/cloudfoundry/buildpacks-ci/blob/31a3fd134614039b21be2ae258de9be196585176/pipelines/config/dependency-builds.yml). Currently, only buildpacks hosted at `github.com/cloudfoundry/*-cnb` (or buildpacks that are redirected to from a matching URL) are supported.
* The strategy for updating dependencies (i.e. keeping all versions, keeping only the latest version, keeping `<n>` versions per version line) must be supported by the pipeline and specified per buildpack

### Example

The [go-dist buildpack](https://github.com/paketo-buildpacks/go-dist) includes the latest two Go versions for each supported version line. It could use a [scheduled Github workflow](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#scheduled-events) to periodically request all versions of Go from the Dep Server, determine which versions should be included, and update `buildpack.toml` accordingly.

A different Go buildpack could have its own Github workflow which periodically requests all versions of Go from the Dep Server and includes them all in `buildpack.toml`.

## Detailed Explanation

The Dep Server will be hosted at `https://api.deps.paketo.io` and provide a single endpoint: `/v1/dependency`. It will require a query parameter called `name` which is the name of the dependency. It will return an array of objects containing the following metadata:

* `name`: the name of the dependency
* `version`: the version of the dependency
* `uri`: the URL of the dependency artifact
* `sha256`: the SHA256 checksum of the dependency artifact
* `stacks`: an array of objects containing the following metadata:
  * `id`: the ID of the stack on which the dependency is supported
  * `mixins`: an array of mixin names which are required for the dependency to work on the stack (will be omitted if no mixins are required)
* `source`: the URL of the dependency artifact source
* `source_sha256`: the SHA256 checksum of the dependency artifact source
* `deprecation_date`: the [RFC3339](https://tools.ietf.org/html/rfc3339)-formatted date on which the dependency will be deprecated (will be empty if deprecation date is not known)

The order of these objects is not guaranteed. If a dependency is rebuilt, a new entry in the array will be added and the old version removed.

As an example:

```
$ curl -sL https://api.deps.paketo.io/v1/dependency?name=go
[
  {
    "name": "go",
    "version": "1.15",
    "sha256": "29d4ae84b0cb970442becfe70ee76ce9df67341d15da81b370690fac18111e63",
    "uri": "https://deps.paketo.io/go/go_1.15_linux_x64_bionic_29d4ae84.tgz",
    "stacks": [
      {
        "id": "io.buildpacks.stacks.bionic"
      },
      {
        "id": "io.paketo.stacks.tiny",
        "mixins": ["some-required-mixin"]
      }
    ],
    "source": "https://dl.google.com/go/go1.15.src.tar.gz",
    "source_sha256": "69438f7ed4f532154ffaf878f3dfd83747e7a00b70b3556eddabf7aaee28ac3a",
    "deprecation_date": ""
  },
  {
    "name": "go",
    "version": "1.13.15",
    "sha256": "b4ff131749bea80121374747424f2f02bb7dbdabc69b5aad8cff185f15e1aec9",
    "uri": "https://deps.paketo.io/go/go_1.13.15_linux_x64_bionic_b4ff1317.tgz",
    "stacks": [
      {
        "id": "io.buildpacks.stacks.bionic"
      },
      {
        "id": "io.paketo.stacks.tiny",
        "mixins": ["some-required-mixin"]
      }
    ],
    "source": "https://dl.google.com/go/go1.13.15.src.tar.gz",
    "source_sha256": "5fb43171046cf8784325e67913d55f88a683435071eef8e9da1aa8a1588fcf5d",
    "deprecation_date": "2020-08-11T00:00:00Z"
  },
  {
    "name": "go",
    "version": "1.14.7",
    "sha256": "fda51caebe2799b1424f8f174a9e1e2e91649e79ad2f1f504e60f8e8d588027c",
    "uri": "https://deps.paketo.io/go/go_1.14.7_linux_x64_bionic_fda51cae.tgz",
    "stacks": [
      {
        "id": "io.buildpacks.stacks.bionic"
      },
      {
        "id": "io.paketo.stacks.tiny",
        "mixins": ["some-required-mixin"]
      }
    ],
    "source": "https://dl.google.com/go/go1.14.7.src.tar.gz",
    "source_sha256": "064392433563660c73186991c0a315787688e7c38a561e26647686f89b6c30e3",
    "deprecation_date": ""
  }
]
```


## Rationale and Alternatives

### Direct file storage

The dependency artifacts and their metadata could be stored in a file store such as Amazon S3. This would tightly couple us to that file store and make migrating away from it or changing the metadata format very difficult. For example, if we wanted to add a new property to the metadata called `is_supported`, we would either need to add that field to all existing metadata objects or add logic to every buildpack consuming it that handles the field potentially being missing. But with the Dep Server, we could calculate and include that field on-the-fly.

### A more fully-featured API

We could provide endpoints such as `/v1/dependency/<name>/latest`, `/v1/dependency/<name>/version_lines`, etc. The single proposed `/v1/dependency` supports all existing functionality, and we can always add more endpoints in the future.

### A different push model

Any push model will have the same issues mentioned above in the Motivation section

## Implementation

A new repository, `github.com/paketo-buildpacks/dep-server`, will be created containing the Dep Server's source code. The server will run in Google App Engine at `https://api.deps.paketo.io`. An SSL certificate for `api.deps.paketo.io` will be created and used by the server.

One concern with this implementation is that the server is a single point of failure which would prevent any buildpack from being able to update its dependencies.

## Prior Art

[semver.io](https://semver.io) is a webservice hosted by Heroku which provides version information for node.js, iojs, npm, yarn, nginx, and mongodb. However, it only provides version numbers, while the Dep Server would provide additional metadata (release date, URL of dependency artifact, URL of source dependency, etc.). The [source repository](https://github.com/heroku/semver.io) has also been archived and new dependencies are not being added.

## Unresolved Questions and Bikeshedding

* How will releasing/versioning of the server be handled? Will it be redeployed on every commit that passes some set of tests?
