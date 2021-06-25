# BP_GO_BUILD_LDFLAGS

## Proposal

Add an environment variable `BP_GO_BUILD_LDFLAGS` which would allow users to
set the value of `-ldflags` for their `go build` command.

## Motivation

The `-ldflags` flag can have complicated values with multiple sets of internal
quotation marks, an example of this complication can be seen in [this
issue](https://github.com/paketo-buildpacks/go-build/issues/129). The goal of
this environment variable is to remove one quotation level hopefully making it
easier to express the `-ldflags` value with little to no escaping.

## Implementation

If `BP_GO_BUILD_LDFLAGS` is set then `-ldflags` plus the value of the
environment variable will be added to the `go build` command.

The following is an example of a cumbersome `BP_GO_BUILD_FLAGS` caused by
`-ldflags`:

`BP_GO_BUILD_FLAGS="-ldflags=\"-extldflags '-f no-PIC -static'\" -tags=osusergo,netgo,embedfs"`

If the same flag set were to be written using the proposed
`BP_GO_BUILD_LDFLAGS` it would look like this:

`BP_GO_BUILD_LDFLAGS="-extldflags '-f no-PIC -static'" BP_GO_BUILD_FLAGS="-tags=osusergo,netgo,embedfs"`

### Examples of Flag Merging

1.
```
Given BP_GO_BUILD_LDFLAGS="-extldflags '-f no-PIC -static'"
Given BP_GO_BUILD_FLAGS is unset

The resulting flags would be:
-ldflags="-extldflags '-f no-PIC -static'" -buildmode pie . # the buildmode and target are defaults added by the buildpack
```
Summary: If no other flags are set by the user the `BP_GO_BUILD_LDFLAGS` will
be treated as a flag set on its own and be included as part of the build
command.

2.
```
Given BP_GO_BUILD_LDFLAGS="-extldflags '-f no-PIC -static'"
Given BP_GO_BUILD_FLAGS="-tags=osusergo,netgo,embedfs"

The resulting flags would be:
-ldflags="-extldflags '-f no-PIC -static'" -tags=osusergo,netgo,embedfs -buildmode pie .
```
Summary: If `BP_GO_BUILD_LDFLAGS` and `BP_GO_BUILD_FLAGS` is set and
`BP_GO_BUILD_FLAGS` does not include `-ldflags` then the `BP_GO_BUILD_LDFLAGS`
will set `-ldflags` in the existing flag set.

3.
```
Given BP_GO_BUILD_LDFLAGS="-extldflags '-f no-PIC -static'"
Given BP_GO_BUILD_FLAGS="-ldflags='some-ldflags' -tags=osusergo,netgo,embedfs"

The resulting flags would be:
-ldflags="-extldflags '-f no-PIC -static'" -tags=osusergo,netgo,embedfs -buildmode pie .
```
Summary: If `BP_GO_BUILD_LDFLAGS` and `BP_GO_BUILD_FLAGS` is set and
`BP_GO_BUILD_FLAGS` does include `-ldflags` then the `BP_GO_BUILD_LDFLAGS` will
overwrite `-ldflags` in the existing flag set.


## Unresolved Questions and Bikeshedding (Optional)

* Is this necessary? Should we just document the escaping better? Should we do
  both?

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
