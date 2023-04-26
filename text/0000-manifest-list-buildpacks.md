# Publish multi-arch buildpacks

## Summary

In order to enable end users to create arm64 images with paketo buildpacks I am proposing that paketo start publishing multi-arch buildpack images for all buildpacks. @dmikusa put together [this](https://github.com/dmikusa/paketo-arm64) excellent guide for building arm64 containers with paketo buildpacks, but it puts a heavy burden on end users to create and maintain copies of paketo buildpacks. This proposal is to start publishing manifest list images that support x86_64 and arm64 architectures. This would be accomplished by using `docker manifest` or similar.

For simplicity I will refer to x86_64 as amd64 throughout this document.

## Motivation

The number one question I get about [paketo] buildpacks is whether they support arm. It is safe to say that workloads are generally moving to arm processors and end users are already evaluating how to build containers on arm. It is difficult for me as an end user to seriously consider building arm images with paketo buildpacks without putting in some engineering effort into building arm versions of the paketo buildpacks I may need. While the above example is definitely helpful, a lot of the steps can be built into the github actions workflows that create and release buildpacks for general consumption. I believe arm support was the number one requested roadmap item for 2023, and this proposal is an attempt to jump start that process.


## Detailed Explanation

Right now binaries are created on/for amd64 and then packaged up into buildpacks using pack. It should be easy to create binaries for arm64 which can then be packaged up into buildpacks using pack. These architecture-specific buildpacks can be pushed to a registry with a platform specific tag as shown in the examples below. 

* `paketobuildpacks/ca-certificates:3.6-amd64`
* `paketobuildpacks/ca-certificates:3.6-arm64`

The last step would be to create a manifest list image using `docker manifest` commands (or similar) and push it to the registry.

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

### Changes to packit

`Os` and `Architecture` string fields can be added to the [`Dependency`](https://github.com/paketo-buildpacks/packit/blob/v2/postal/buildpack.go#L15) struct in `packit/postal` to allow buildpacks to interrogate and use the new metadata when determining what external dependencies to download. This will allow `buildpack.toml` files to be updated to add in the `os` and `architecture` metadata for all dependencies. They would all be set to something like `os=linux` and `architecture=amd64` initially.

Some logic can be added to the [Resolve](https://github.com/paketo-buildpacks/packit/blob/18202009038b0df285ba0fb7d8b43abbf60d3ed0/postal/service.go#L89) method of `packit/postal` to pick a version that matches the `GOOS` environment variable whenever the `os` and `architecture` fields have been specified.

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

These can then be pushed using skopeo with the above mentioned architecture-specific tags. Finally some `docker manifest` commands can be used to create the manifest list image and then push it to the registry.

Users would have the same experience using the manifest list images on amd64, while allowing those who want/need arm64 images to benefit as well.


## Prior Art

As mentioned above @dmikusa put together [this](https://github.com/dmikusa/paketo-arm64) excellent guide for building arm64 images with paketo buildpacks. This repo, based on the aforementioned example, is publishing arm version of paketo builders and buildpacks. While it is great to see community involvement in pushing this forward, I think it is time for the paketo maintainers to agree on a path forward so the community can start contributing towards that goal.


## Unresolved Questions and Bikeshedding

### Testing on arm64

As discussed [here](https://github.com/actions/runner-images/issues/5631), github actions currently only supports amd64 runners. This means that unit and integration tests cannot be run on arm64.

There are two ways to approach this issue. The first is to only run tests for amd64 and label all arm64 artifacts as experimental. The second is to use self-hosted or third-party arm64 runners so everything can be tested on both architectures. Given that paketo bulidpacks are used for production workloads, I think having arm64 runners will be necessary.
