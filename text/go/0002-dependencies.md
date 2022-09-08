# Decide Which Go Dependencies Will Be Paketo-hosted

## Proposal

The following dependencies should be removed as Paketo-hosted dependencies:
* [Go Distribution](https://github.com/paketo-buildpacks/go-dist/blob/main/buildpack.toml)


## Rationale

### Go Distribution

Remove the Paketo-hosted dependency.

The buildpack can use the dependency that is provided by Go which can be parsed
from a JSON payload of thier [download
page](https://go.dev/dl/https://go.dev/dl/?mode=json&include=all) with little
to no modification. The precedence for this payload page existing can be found
in the [Go Docs for the
website](https://pkg.go.dev/golang.org/x/website/internal/dl). The payload
includes a SHA256 from Go meaning the artifact can be verified from the
upstream. Here is a [proof of concept
PR](https://github.com/paketo-buildpacks/go-dist/pull/442) showing the
buildpack using the dependencies directly from the Go upstream. Because this
dependency can be consumed from a trusted source, we should stop hosting it
ourselves.
