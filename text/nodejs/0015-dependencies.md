# Decide which `nodejs` dependencies will be Paketo-hosted

## Proposal

The following dependencies should be removed as Paketo-hosted dependencies:
* [yarn](https://github.com/paketo-buildpacks/yarn/blob/main/buildpack.toml)
* [cycloneDX (node-module-bom)](https://github.com/paketo-buildpacks/node-module-bom/blob/main/buildpack.toml)

The following dependency should be Paketo-hosted for bionic only and pulled directly from upstream for jammy
* [node-engine](https://github.com/paketo-buildpacks/node-engine/blob/main/buildpack.toml)

## Rationale

### node-engine

Keep the bionic dependency as a Paketo-hosted dependency only and pull jammy from upstream

The Paketo node-engine buildpack supports using the system's CA store, which is not a default feature in node.
This feature is currently enabled by compiling node from source with the `--openssl-use-def-ca-store` flag.
But it can also be enabled by setting `NODE_OPTIONS` to `--use-openssl-ca`.
Node can be pulled directly from upstream for jammy.
However, versions 18+ are not compatible with bionic without compiling from source.
Therefore, this RFC proposes making the bionic dependency a Paketo-hosted dependency
and pulling the jammy dependency directly from upstream.

### yarn

Remove the Paketo-hosted dependency.

It looks like yarn is downloaded directly from a [Github release url](https://github.com/paketo-buildpacks/dep-server/blob/7098d1969b374b03da1d7cd4b5ca53596609a646/pkg/dependency/yarn.go#L109).
This may be replicated in the buildpack's `build` stage if the top level tar file directory can be removed.  Therefore, this RFC proposes removing yarn as a Paketo-hosted dependency.

### cycloneDX (node-module-bom)

Remove the Paketo-hosted dependency.

The node-module-bom Paketo buildpack installs the [CycloneDX Node Module
tool](https://github.com/CycloneDX/cyclonedx-node-module) into a layer. While this dependency is currently a Paketo-hosted
dependency, it could also be installed using the `npm` cli.
Therefore, this RFC proposes removing cycloneDX as a Paketo-hosted dependency.
