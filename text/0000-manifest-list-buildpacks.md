# Publish multi-arch buildpacks

## Summary

In order to enable end users to create arm64 images with paketo buildpacks I am proposing that paketo start publishing multi-arch buildpack images for all buildpacks. @dmikusa put together [this](https://github.com/dmikusa/paketo-arm64) excellent guide for building arm64 containers with paketo buildpacks, but it puts a heavy burden on end users to create and maintain copies of paketo buildpacks. This proposal is to start publishing manifest list images that support x86_64 and arm64 architectures. This would be accomplished by using `docker buildx imagetools create` or similar.

For simplicity I will refer to x86_64 as amd64 throughout this document.

## Motivation

The number one question I get about [paketo] buildpacks is whether they support arm. It is safe to say that workloads are generally moving to arm processors and end users are already evaluating how to build containers on arm. It is difficult for me as an end user to seriously consider building arm images with paketo buildpacks without putting in some engineering effort into building arm versions of the paketo buildpacks I may need. While the above example is definitely helpful, a lot of the steps can be built into the github actions workflows that create and release buildpacks for general consumption. I believe arm support was the number one requested roadmap item for 2023, and this proposal is an attempt to jump start that process.

## Detailed Explanation

Right now binaries are created on/for amd64 and then packaged up into buildpacks using pack. It should be easy to create binaries for arm64 which can then be packaged up into buildpacks using pack. These architecture-specific buildpacks can be pushed to a registry with a platform specific tag as shown in the examples below. 

* `paketobuildpacks/ca-certificates:3.6-amd64`
* `paketobuildpacks/ca-certificates:3.6-arm64`

The last step would be to create a manifest list image using `docker buildx imagetools create` (or similar) and push it to the registry.

Users would pull the manifest list image such as: `paketobuildpacks/ca-certificates:3.6`

This is what the manifest might look like for `paketobuildpacks/ca-certificates:3.6` (as an example)

```
# crane manifest paketobuildpacks/ca-certificates:3.6 | jq .
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
  "manifests": [
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 12345,
      "digest": "sha256:abcdefchijklmnodka0204kdkbjladkj02jfjbe2458801ekdbbks024f555kdkd",
      "platform": {
        "architecture": "amd64",
        "os": "linux"
      }
    },
    {
      "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
      "size": 12345,
      "digest": "sha256:3333defchijklmnodka0204kdkbjladkj02jfjbe2458801ekdbbks024f555kdkd",
      "platform": {
        "architecture": "arm64",
        "os": "linux"
      }
    }
  ]
}
# 
```

## Rationale and Alternatives

The upstream pack project is already creating multi-arch images for pack and the lifecycle using `docker buildx`, which creates manifest list images. An alternative approach is to create and publish separate images that are tagged by architecture. This would be the steps I mentioned above without the final manifest list image. I think this is an anti-pattern at this point given that multi-arch images are already a norm. I also suspect end users would end up creating their own manifest list images anyway. I think the biggest driver for this is to avoid end users cloning and rebuilding paketo buildpacks.

## Implementation

### Upstream changes to pack to consider

[This](https://github.com/buildpacks/rfcs/blob/main/text/0096-remove-stacks-mixins.md) rfc captures a lot of the concepts implemented in the spec changes. The following [PR](https://github.com/buildpacks/spec/pull/336/files#) to the buildpack spec introduces two new environment variables that will be set by the lifecycle during the detect and build phases, `CNB_TARGET_OS` and `CNB_TARGET_ARCH`. These changes are available in version `0.12` of the platform api as outlined [here](https://github.com/buildpacks/spec/pull/335). These changes were partially implemented in [this](https://github.com/buildpacks/lifecycle/issues/743) issue, but they have not yet made into pack ([here](https://github.com/buildpacks/pack/blob/v0.30.0-pre1/builder/config_reader.go)).

### Proposed approach 

Once all upstream changes to pack have been fully implemented and the newest version of pack and the lifecycle are being used the values in `CNB_TARGET_OS` and `CNB_TARGET_ARCH` will be set by paketo in the builder config toml. This means the changes I'm proposing to  `libpak` and `packit` below can just read those environment variables and match any dependencies to the appropriate os and architecture. 

Since there are a lot of moving pieces to this project, I suggest the change from using stacks to targets (run and build images) be done separately. This would mean that the `CNB_TARGET_OS` and `CNB_TARGET_ARCH` environment variables would need to be set in the function/method that reads the buildpack. At build time buildpacks should attempt to read those environment variables if set, but otherwise fall back to determining os and architecture from another source such as `GOOS` and `GOARCH` environment variables. This should ultimately match whatever is used to set those values in the builder too.

One benefit to this approach is that it would make the new multi-arch buildpacks backwards compatible with older builders. If someone uses new (proposed) multi-arch buildpacks with an older version of pack, or with a stack-based builder, the build can still work. This could happen if someone set up CI to create a custom builder and has not upgraded the version of pack, or if they pinned the lifecycle version when creating the builder.

### Changes to packit

`Os` and `Architecture` string fields can be added to the [`Dependency`](https://github.com/paketo-buildpacks/packit/blob/v2/postal/buildpack.go#L15) struct in `packit/postal` to allow buildpacks to interrogate and use the new metadata when determining what external dependencies to download. This will allow `buildpack.toml` files to be updated to add in the `os` and `architecture` metadata for all dependencies. They would all be set to something like `os=linux` and `architecture=amd64` initially.

Some logic can be added to the [Resolve](https://github.com/paketo-buildpacks/packit/blob/18202009038b0df285ba0fb7d8b43abbf60d3ed0/postal/service.go#L89) method of `packit/postal` to pick a version that matches the `GOOS` and `GOARCH` environment variables whenever the `os` and `architecture` fields have been specified.

### Changes to libpak

`Os` and `Architecture` string fields can be added to the [`BuildpackDependency`](https://github.com/paketo-buildpacks/libpak/blob/v1.65.0/buildpack.go#L66) struct in `libpak` to allow buildpacks to interrogate and use the new metadata when determining what external dependencies to download. 

Some logic can be added to the [NewBuildpackMetadata](https://github.com/paketo-buildpacks/libpak/blob/v1.65.0/buildpack.go#LL325C4-L325C4) function of `libpak` to pick a version that matches the `GOOS` and `GOARCH` environment variables whenever the `os` and `architecture` fields have been specified.

libpak uses [buildpacks/libcnb](https://github.com/buildpacks/libcnb/blob/82f0d2fde60df311c09914cd993acdbfc40da1e6/buildpack.go#L103) for the bulidpack.toml. Since the `Metadata` field is map of strings (keys) to interfaces (values), no changes should be needed here.


### Changes to `buildpack.toml` files

There are primarily two types of buildpacks: those that run without any external dependencies such as [ca-certificates](https://github.com/paketo-buildpacks/ca-certificates), and those that download and install external dependencies such as [azul-zulu](https://github.com/paketo-buildpacks/azul-zulu). For the former no changes should be needed other than compiling for amd64 and arm64. The later will require some changes to `buildpack.toml`.

The spec for [`buildpack.toml`](https://github.com/buildpacks/spec/blob/main/buildpack.md) makes no mention of `os` or `architecture`, which means the adding those fields to entries in the `metadata.dependencies` list seems like a perfectly reasonable option. [This](https://github.com/paketo-buildpacks/rfcs/blob/decouple-dependencies/text/0000-decouple-dependencies.md) rfc proposes adding `os` and `arch` fields to the versions in the dependency table. I suggest sticking with the same field names that are used in the manifest image (`os` and `architecture`) for consistency, but the general idea is the same.

Here is an example of what the dependencies would look like.

```toml
  [[metadata.dependencies]]
    cpe = "cpe:2.3:a:golang:go:1.18.4:*:*:*:*:*:*:*"
    id = "go"
    licenses = ["BSD-3-Clause"]
    name = "Go"
    stacks = ["*"]
    strip-components = 1
    version = "1.18.4"
    os = "linux"
    architecture = "amd64"
    purl = "pkg:generic/go@go1.19?checksum=c9b099b68d93f5c5c8a8844a89f8db07eaa58270e3a1e01804f17f4cf8df02f5&download_url=https://go.dev/dl/go1.18.4.linux-amd64.tar.gz"
    sha256 = "c9b099b68d93f5c5c8a8844a89f8db07eaa58270e3a1e01804f17f4cf8df02f5"
    source = "https://go.dev/dl/go1.18.4.linux-amd64.tar.gz"
    source_sha256 = "c9b099b68d93f5c5c8a8844a89f8db07eaa58270e3a1e01804f17f4cf8df02f5"
    uri = "https://go.dev/dl/go1.18.4.linux-amd64.tar.gz"


  [[metadata.dependencies]]
    cpe = "cpe:2.3:a:golang:go:1.18.4:*:*:*:*:*:*:*"
    id = "go"
    licenses = ["BSD-3-Clause"]
    name = "Go"
    stacks = ["*"]
    strip-components = 1
    version = "1.18.4"
    os = "linux"
    architecture = "arm64"
    purl = "pkg:generic/go@go1.19?checksum=35014d92b50d97da41dade965df7ebeb9a715da600206aa59ce1b2d05527421f&download_url=https://go.dev/dl/go1.18.4.linux-arm64.tar.gz"
    sha256 = "35014d92b50d97da41dade965df7ebeb9a715da600206aa59ce1b2d05527421f"
    source = "https://go.dev/dl/go1.18.4.linux-arm64.tar.gz"
    source_sha256 = "35014d92b50d97da41dade965df7ebeb9a715da600206aa59ce1b2d05527421f"
    uri = "https://go.dev/dl/go1.18.4.linux-arm64.tar.gz"
```

### Github actions and workflows

I haven't looked at github workflows for all buildpacks, but I believe [jam](https://github.com/paketo-buildpacks/jam) is being used to package buildpacks. I did see skopeo being used to push images ([cpython](https://github.com/paketo-buildpacks/cpython/blob/main/.github/workflows/push-buildpackage.yml#L62)).

My proposal is to update jam to create buildpacks for amd64 and arm64. I haven't used jam yet, so I don't have specific code changes for it and would appreciate thoughts on how this could be added.

These can then be pushed using skopeo with the above mentioned architecture-specific tags. Finally `docker buildx imagetools create` can be used to create the manifest list image and then push it to the registry.

Users would have the same experience using the manifest list images on amd64, while allowing those who want/need arm64 images to benefit as well.


### Related Discussion

[This](https://github.com/orgs/paketo-buildpacks/discussions/23) discussion also captures a lot of what is in this document.

## Prior Art

As mentioned above @dmikusa put together [this](https://github.com/dmikusa/paketo-arm64) excellent guide for building arm64 images with paketo buildpacks. This repo, based on the aforementioned example, is publishing arm version of paketo builders and buildpacks. While it is great to see community involvement in pushing this forward, I think it is time for the paketo maintainers to agree on a path forward so the community can start contributing towards that goal.


## Unresolved Questions and Bikeshedding

### Testing on arm64

As discussed [here](https://github.com/actions/runner-images/issues/5631), github actions currently only supports amd64 runners. This means that unit and integration tests cannot be run on arm64.

There are two ways to approach this issue. The first is to only run tests for amd64 and label all arm64 artifacts as experimental. The second is to use self-hosted or third-party arm64 runners so everything can be tested on both architectures. Given that paketo bulidpacks are used for production workloads, I think having arm64 runners will be necessary.

I set up [jericop/cnb-builder](https://github.com/jericop/cnb-builder) to create and test multi-arch jammy builders. It uses github actions with both amd64 and arm64 runners, so you can view workflow runs to see build and test output and validate behavior. After some testing using the latest pre-release of pack (0.30.0-pre1) I confirmed that the environment variables are not being set yet. I plan to update the version of pack once further changes have been implemented.