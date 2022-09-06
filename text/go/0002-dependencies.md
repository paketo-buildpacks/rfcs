# Decide Which Go Dependencies Will Be Paketo-hosted

## Proposal

The following dependencies should be removed as Paketo-hosted dependencies:
* [Go Distribution](https://github.com/paketo-buildpacks/go-dist/blob/main/buildpack.toml)


## Rationale

### Go Distribution

Remove the Paketo-hosted dependency.

The buildpack can use the dependency that is provided by Go on their [download
page](https://go.dev/dl/) with little to no modification. Here is a [proof of
concept PR](https://github.com/paketo-buildpacks/go-dist/pull/442) showing the
buildpack using the dependencies directly from the Go upstream. Because this
dependency can be consumed from a trusted source, we should stop hosting it
ourselves.
