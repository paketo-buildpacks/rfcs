# Addendum to RFC 0010 Dependency Mappings

This RFC serves as an addendum to the [RFC 0010 Dependency Mappings](./0010-dependency-mappings.md)

## Proposal

The addendum proposes that bindings of type `dependency-mapping` can and should include the dependency lookup digest as a `checksum` in the form of `<algorithm>:<hash>` instead of a `sha256` in the form of `<hash>`.

If the digest is provided in the form of `<hash>`, it will be assumed to be of algorithm type `sha256`.

The dependency mapping implementation in the project will continue to support the use of a `sha256` as long as the `sha256` `buildpack.toml` field is supported; however, users of this feature should ideally use a `checksum`.

## Motivation

The `checksum` field has been recently introduced as a means of supporting a variety of different hashing algorithms that dependencies may be provided in, beyond just the `sha256`. In order to make this change, dependency mappings, which leverage the dependency `sha256` must be able to use the new `checksum` field as well.

## Implementation

An example of a Kubenetes spec-type service binding using a `checksum` for a dependency mapping looks like:

```
$SERVICE_BINDING_ROOT
└── my-dependency-binding
    ├── type -> "dependency-mapping"
    ├── sha256:b4cb31162ff6d7926dd09e21551fa745fa3ae1758c25148b48dadcf78ab0c24c -> https://example.com/dep-1.tgz
    └── sha256:efa6d87993ff21615e2d8fc0c98e07ff357fc9f3b9bd93c2cf58ba7f2b6fd2e0 -> https://example.com/dep-2.tgz
```

## Prior Art
- https://github.com/paketo-buildpacks/packit/pull/389
- https://github.com/paketo-buildpacks/rfcs/pull/251
