# Add pURL Field to the Dependency Server Metadata

## Summary

Add a field for pURLs into the dependency server schema.
This RFC is an addendum to [RFC #0009](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0009-dep-server.md)

## Motivation

Currently, the dependency server offers a lot of valuable information about the
files it hosts. However, it currently does not have the capacity to supply
pURLs. This field should be added to the dependency server because pURLs are an
industry standard package identifier that allow dependencies to be accurately
identified by the end user. Package URLs are also a standard supported by the CycloneDX Bill of Materials format, and are [integrated with a number of other tools](https://github.com/package-url/purl-spec#users-adopters-and-links). Overall, package URLs can provide rich information beyond what's available via CPEs alone, making them a strong choice to include on our dependency metadata.

## Implementation

The following field should be added to the dependency server output:

* `purl`: a string which is a pURL for that dependency that conforms to the
  [pURL Specification](https://github.com/package-url/purl-spec).

An example of the new output:
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
    "deprecation_date": "",
    "licenses": ["BSD-3-Clause"],
    "purl": "pkg:generic/go@1.15?download_url=https://dl.google.com/go/go1.15.src.tar.gz&checksum=sha256:69438f7ed4f532154ffaf878f3dfd83747e7a00b70b3556eddabf7aaee28ac3a"
  }
]
```
