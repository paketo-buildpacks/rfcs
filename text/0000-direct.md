# Use direct processes and exec.d

## Summary

This RFC proposes that we move all Paketo buildpacks to use `direct` process types and `exec.d` interface instead of `profile.d` interface and `direct = false` process types wherever possible without breaking backwards compatibility from an end user perspective.

## Motivation

As of Buildpacks [RFC 0093](https://github.com/buildpacks/rfcs/blob/main/text/0093-remove-shell-processes.md) we plan on removing any shell specific logic from the lifecycle and instead have non-shell specific interfaces. In preperation for these changes, we should identify all Paketo buildpacks that rely on `profile.d` interface or use `direct = false` process types and convert them to `exec.d` interfaces and `direct = true` process types respectively.

## Detailed Explanation

`direct = false` process types and `profile.d` interfaces have various drawbacks.

- They are slower since they involve shell invocations
- The argument parsing logic can be confusing
- If a process is run with `direct = true` any and all `profile.d` scripts are NOT executed potentially causing issues and confusion around the behaviour of the final application image.

Because of all of the reasons above and others listed in Buildpacks [RFC 0093](https://github.com/buildpacks/rfcs/blob/main/text/0093-remove-shell-processes.md), we should try to move away from any shell specific interfaces.


## Rationale and Alternatives

Rationale per above.

Alternatives - keep using shell specific interfaces until they are deprecated.

## Implementation

The migration path should be relatively easy and most `profile.d` scripts can be easily turned into `exec.d` scripts. Some more details can be found [here](https://github.com/buildpacks/rfcs/blob/main/text/0093-remove-shell-processes.md#layerprofiled)


## Prior Art

- Most libpak based buildpacks already use exec.d interfaces and `direct = true` process types.

## Unresolved Questions and Bikeshedding

TBD
