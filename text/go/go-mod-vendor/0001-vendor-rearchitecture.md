# Go Mod Vendor Rearchitecture

## Proposal

The main functionality provided by the `go-mod-vendor` buildpack will be to
provide vendored dependencies using the `go mod vendor` command. More
information about go modules can be found [here](https://golang.org/ref/mod).

`go mod vendor` first looks for the `go.mod` file in the app root directory,
which would be there as a result of running `go mod init` before the buildpack
is run. This would be the app developer's responsibility if they want
to use go modules.

The `go.mod` file lives at the root of the app directory and  contains the app
dependencies, and gets updated by various go commands such as `go get`, `go
mod tidy` or in this case `go mod vendor`.

The [official documentation](https://golang.org/ref/mod#tmp_25) explains how go
modules deal with vendoring:

> The `go mod vendor` command constructs a directory named `vendor` in the main
> module's root directory that contains copies of all packages needed to
> support builds and tests of packages in the main module.

> Once vendoring is enabled, packages are loaded from the `vendor` directory
> instead of accessing the network or the module cache.

## Integration

The proposed buildpack requires `go` and provides none.

The former `go-mod` buildpack used to provide `go-mod`.

## Renaming

The buildpack will be renamed to `go-mod-vendor` from `go-mod`. This will more
clearly illustrate the specific function of the buildpack.

The original `go-mod` buildpack contains logic that deals with binary building.
Binary building logic will be removed from this buildpack and instead becomes a
responsibility of the [`go-build`](https://github.com/paketo-buildpacks/go-build) buildpack.

## Implementation

Detection will pass if a `go.mod` file is present in the app's source code.

On detection, the buildpack will perform the following steps in the Build
phase:

- Retrieve or create a `mod-cache` layer, which will be a `cache` layer.
- Set the `GOPATH` to point at the `mod-cache` layer.
- Run `go mod vendor`.

## Motivation

A big effort of the Paketo project is to move towards buildpacks that are
responsible for a single function making the whole buildpack family structure
more flexible, lightweight, and easier to maintain. With the proposed changes,
the sole responsibility of this buildpack becomes managing application
dependencies with go modules. As mentioned, the binary building logic gets
offloaded to the `go-build` buildpack.

## Source Material (Optional)

[Golang Documentation on Vendoring](https://golang.org/ref/mod#tmp_25)
