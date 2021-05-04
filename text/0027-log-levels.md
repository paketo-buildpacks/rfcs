# Common Logging Levels for Buildpacks

## Summary

All Paketo buildpacks should provide a mechanism for tuning log verbosity. To
enable this configuration, the buildpacks should respect a `BP_LOG_LEVEL`
environment variable.

## Motivation

The Paketo buildpacks aim to provide transparent and understandable feedback to
buildpack users. Part of this feedback is provided by the log output emitted by
each buildpack. Buildpack users and authors will want see log output with
different levels of granularity in the details they provide. For instance, some
buildpack users may only want to know when the buildpack is warning the user
about possible issues. Alternatively, to aid in some debugging scenarios, it
may be useful to emit log output that including internal implementation details
and state. Clearly providing log output that succeeds in serving both of these
needs is not possible. Instead, we should allow buildpack users to tune the log
output to suite their needs.

## Detailed Explanation

All buildpacks will provide a `BP_LOG_LEVEL` environment variable to allow for
the configuration of log output. This variable will support 2 acceptable
options: `INFO`, and `DEBUG`. The default option, should none be provided by
the user, will be `INFO`. While this RFC will not outline detailed specifics
for what logs should appear at each level, a basic description of their
purposes is included below.

* `INFO`: log information about the progress of the build process
* `DEBUG`: log debugging information about the progress of the build process

The `DEBUG` level is a superset of the `INFO` level. The buildpack will emit
everything you would see at the `INFO` level along with the addition of debug
output.

This RFC intentionally limits the number of supported options to 2 as providing
more than that is likely to create confusion for both buildpack authors and
users. These options may be amended in a future RFC.

Additionally, the log level setting will only apply to the log output from the
buildpack itself. Buildpacks may also emit logs from tools they invoke as part
of their build process. The output of these tools should be independently
configurable and not influenced by the `BP_LOG_LEVEL` setting. For example, a
buildpack user could configure their build with `BP_LOG_LEVEL=DEBUG` and
`NPM_LOG_LEVEL=DEBUG` to see both the debug logs from the buildpack itself and
also the debug log output from the `npm` tool.

## Rationale and Alternatives

The Java buildpacks currently support a `BP_DEBUG` flag that can be enabled to
emit debug information. While this does support the 2 proposed log levels, if
you assume that disabling `BP_DEBUG` is equivalent to the `INFO` log level as
described above, it isn't as flexible or extensible.

## Implementation

Each buildpack should allow the user to set the `BP_LOG_LEVEL` environment
variable to one of the given options, and tailor their log output to that
option. This could be acheived via a common library integration through either
`packit` or `libpak`, but is left to the buildpack core teams to decide.

## Prior Art

* https://reflectoring.io/logging-levels/ for a standardized set of log levels
* https://dave.cheney.net/2015/11/05/lets-talk-about-logging for an argument on
  limiting the set of log levels in use
