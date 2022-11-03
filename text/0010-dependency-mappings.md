# Dependency Mappings

## Summary

We should provide a standard mechanism for mapping dependencies to new URIs that works across all Paketo buildpacks.

## Motivation

Consumers of Paketo buildpacks may be building in an environment where certain dependency URIs are inaccessible (due to restrictive firewall rules for example). Operators may want host copies of certain dependencies at different accessible URIs.

## Detailed Explanation

### Discovery
If one or more bindings of kind or type `dependency-mapping` are present, buildpacks should respect any URIs found in the binding. The lookup digest should be included as `checksum` in the form of `<algorithm>:<hash>` (or `sha256` in the form of `<hash>`) of the dependency should be used to lookup mapped URIs.

If the digest is provided in the form of `<hash>`, it will be assumed to be of algorithm type `sha256`.

The dependency mapping implementation in the project will continue to support the use of a `sha256` as long as the `sha256` `buildpack.toml` field is supported; however, users of this feature should ideally use a `checksum`.

### CNB Bindings Specification Example
Using https://github.com/buildpacks/spec/blob/main/extensions/bindings.md:
```
<platform>
└── bindings
    └── my-dependency-binding
        ├── metadata
        │   └── kind -> "dependency-mapping"
        └── secret
            ├── sha256:b4cb31162ff6d7926dd09e21551fa745fa3ae1758c25148b48dadcf78ab0c24c -> https://example.com/dep-1.tgz
            └── sha256:efa6d87993ff21615e2d8fc0c98e07ff357fc9f3b9bd93c2cf58ba7f2b6fd2e0 -> https://example.com/dep-2.tgz
```

### Service Binding Specification for Kubernetes Example
Using https://github.com/k8s-service-bindings/spec:
```
$SERVICE_BINDING_ROOT
└── my-dependency-binding
    ├── type -> "dependency-mapping"
    ├── sha256:b4cb31162ff6d7926dd09e21551fa745fa3ae1758c25148b48dadcf78ab0c24c -> https://example.com/dep-1.tgz
    └── sha256:efa6d87993ff21615e2d8fc0c98e07ff357fc9f3b9bd93c2cf58ba7f2b6fd2e0 -> https://example.com/dep-2.tgz
```

## Rationale and Alternatives

Alternatively, open source users could package offline versions of the buildpacks. However, this requires knowledge and labor. Additionally, users who only consume a handful of dependencies may not want to pay the cost of downloading very large offline builder images that contain many dependencies that are irrelevant to their use case.

Another alternative would be for buildpacks to expose URI options for each dependency using environment configuration. However this may result in non-standard interfaces or incomplete support for URI mappings.

## Implementation

Before downloading a dependency the buildpack searches all bindings of type `dependency-mapping` for digests matches that of the target dependency. When the buildpack downloads a dependency it should use mapped URI instead of the URI in `buildpack.toml` if a mapping for the dependency exists.

`pack` already allows users to mount arbitrary directories in to the platform dir. `kpack` provides a dedicated UX for bindings. Other platforms are likely to follow suite.

## Prior Art


## Unresolved Questions and Bikeshedding

## Addendums
- November 3, 2022: Modify RFC to leverage `checksum` for digest over a `sha256`
