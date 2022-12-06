# Decide If The Tini Dependency Will Be Paketo-hosted

## Proposal

The [Tini](https://github.com/paketo-buildpacks/tini/blob/main/buildpack.toml)
dependency should be removed as Paketo-hosted dependencies.

## Rationale

### Tini

Remove the Paketo-hosted dependency.

Currently the buildpack uses a binary that is compiled and hosted by Paketo.
However, the author of `tini` attaches a static binary with the releases of
`tini`. These static binaries appear to be compatible with most linux
distributions and are compatible with the current buildpack which can be seen
in this [proof of concept
PR](https://github.com/paketo-buildpacks/tini/pull/274). There are multiple
methods of doing artifact verification with both a shasum and as well an
armored ASCII file that can be used for PGP verification. Because of these
factors we should stop hosting `tini` ourselves.
