# Paketo Community Go Generate Buildpack.

## Proposal

An optional buildpack for the Go language family that runs `go generate`.


## Motivation

For some Go applications, generated files are not committed to the repository.
They are expected to be generated at buildtime (for example, generating
embedded files.)

Technically, this buildpack would run before the `go-build` buildpack
in a custom builder's configuration as we are not looking to integrate
this buildpack into the Go language family buildpack
[at this time](https://github.com/paketo-buildpacks/go/pull/367#issuecomment-771886349).
There is [another RFC](https://github.com/paketo-buildpacks/go/pull/367)
for adopting this buildpack into the Go language family buildpack if it makes sense.

## Implementation

A new `go-generate` buildpack will be developed to run the command `go generate ./...`
when `BP_GO_GENERATE=true`.
Eventually, it can be optimized to allow specifying _which_ generate commands
should be run as defined in the other RFC.

### Detection Crtieria

The buildpack will pass detection if the `BP_GO_GENERATE` environment variable
is set to `true`.

### Build Process

The buildpack will run `go generate ./...` in the directory.
