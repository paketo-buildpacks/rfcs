# Add Process Reload library to Paketo

## Summary

Add a standalone library for buildpack authors to quickly incorporate process reload into their `packit v2`-based buildpacks.

## Motivation

Currently, implementing live reload in a buildpack requires the buildpack author to have knowledge of watchexec internals,
such as command line parameters, and have to know when to enable live reload (typically `BP_LIVE_RELOAD_ENABLED`).

The typical implementation pattern involves finding an example buildpack and copy/pasting implementation code from that buildpack
into the new buildpack. This RFC proposes a helper library to implement live reload with a clean division of interface
("live reload") and implementation ("watchexec").

## Detailed Explanation

Create a new repository to host the library: `paketo-buildpacks/libreload-packit`.
See [Implementation](#implementation) for further details.

Going forward, buildpack authors can rely on this library to assist with reloadable processes, instead of making large
PRs that require intimate knowledge of the `watchexec` CLI. Examples:

- [npm-start](https://github.com/paketo-buildpacks/npm-start/pull/160)
- [python-start](https://github.com/paketo-buildpacks/python-start/pull/79)
- [go-build](https://github.com/paketo-buildpacks/go-build/pull/237)

## Rationale and Alternatives

1. Include the library code in packit. See [PR 343](https://github.com/paketo-buildpacks/packit/pull/343).
While we did consider the possibility of including the interface ("live reload") in Packit, we knew that the implementation
("watchexec") was too tightly coupled with `watchexec` to live in Packit.
2. Include the library code in [the `watchexec` buildpack](https://github.com/paketo-buildpacks/watchexec).
We felt that we should not include both library code and buildpack code in the buildpack repository, especially since
in this case having a generic interface ("live reload") implies that eventually another implementation might be possible.

## Implementation

Create a new repository to host the library: `paketo-buildpacks/libreload`.
The root package `reload` will contain an interface that looks something like this:

```go
package reload

import packit "github.com/paketo-buildpacks/packit/v2"

type ReloadableProcessSpec struct {
	WatchPaths []string
	IgnorePaths []string
	Shell string
	VerbosityLevel int
}

type Reloader interface {
	// ShouldEnableLiveReload will return true when live reload is enabled (such as when `BP_LIVE_RELOAD_ENABLED=true`)
	ShouldEnableLiveReload() (bool, error)

	// TransformReloadableProcesses will take in a packit.Process and transform it to a reloadable packit.Process
	// with the appropriate modifications as per the live reload implementation.
	// Also returns the nonReloadable version of the process.
	TransformReloadableProcesses(originalProcess packit.Process, spec ReloadableProcessSpec) (nonReloadable packit.Process, reloadable packit.Process)
}
```

A subpackage `watchexec` would contain the implementation specific to `watchexec`.
Buildpack authors could choose to use the interface or the implementation for testing purposes, depending on the level
of detail they desire to enforce in the tests.

## Prior Art

N/A, although often "common code" has lived in a Packit subpackage.

## Unresolved Questions and Bikeshedding

- Do we really need the abstracted interface ("live reload") when we only have one implementation ("watchexec")?