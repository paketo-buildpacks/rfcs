# Add License Field to the Dependency Server Metadata

Supersedes [RFC #0009](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0009-dep-server.md)

## Summary

Add a field for license information into the dependency server schema.

## Motivation

Currently, the dependency server offers a lot of valuable information about the
files it hosts. However, it currently does not have the capacity to supply
license information. This field should be added to the dependency server
because information about the licesnse(s) of a dependency is a valuable and
necessary piece of information for those that are trying to make sure that
thier apps use license that comply with thier use cases.

## Implementation

The following field should be added to the dependency server output:

* `licenses`: an array of licenses that are used by the dependency

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
    "licenses": ["BSD-3-Clause"]
  }
]
```

## Prior Art

The Java buildpacks provide license information about the dependencies that
they ingest.
