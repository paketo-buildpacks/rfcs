# Standardized Paketo Dependency Metadata Format

## Summary

This proposal suggests that the Paketo project should converge on a single
dependency metadata format.

## Motivation

There are several projects, such as the introduction of ARM or the removal of
stacks, that are being discussed that would force Paketo to update the metadata
for dependencies. It seems prudent that if we are going to have to do a large
update to dependency metadata that it might also be a good time for us to
converge as a project on the dependency metadata format that we should be using
going forward.

This could also be a good first step in converging on shared tooling. By having
a shared dependency metadata format we would have a good common convergence
point to begin building universal tooling for the Paketo project.

## Implementation

The following is the proposed metadata format:

```toml
[[metadata.dependencies]]
checksum = "<dependency algo:checksum>"
id = "<dependency ID>"
uri = "<dependency URI>"
version = "dependency version"

arch = "<dependency compatible architecture>" #optional
cpes = [ "<dependency cpe>" ] #optional
eol-date = "<dependency eol>" #optional
name = "<dependency name>" #optional
os = "<dependency compatible OS>" #optional
purls = [ "<dependency purl>" ] #optional
source = "<dependency source URI>" #optional
source-checksum = "<dependency source algo:checksum>" #optional
strip-components = <number of directories to strip off dependency artifact> #optional

    [[metadata.dependencies.distros]] #optional
    name = "<compatible OS distribution name>"
    version = "<compatible OS distribution version>" #optional

    [[metadata.dependencies.licenses]] #optional
    type = "<license of dependency>"
    uri = "<URI for information of license>" #optional
```

**Note:** Both the `distros` and `licenses` fields are optional, however if
they are given then the non-optional components of them must be set.

**Note:** If `os` or `arch` are not given it should be assumed that the
dependency is OS or Architecture agnostic and is compatible to run on any given
OS or Architecture.

## Prior Art
- The layout of distributions is pulled from the [Buildpacks Spec](https://github.com/buildpacks/spec/blob/main/buildpack.md#buildpacktoml-toml).
