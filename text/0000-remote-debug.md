# Remote Debug

## Summary

The Java buildpack presently supports enabling remote debugging for applications. More buildpacks are looking to enable this functionality. It would be helpful to have a consistent set of environment variables used for enabling remote connections.

## Motivation

The main driver for this is to provide a cohesive experience to Paketo users. It would allow them to use the same environment variables to enable remote debugging across multiple language families.

## Detailed Explanation

As a Paketo user, I want to be able to enable debug support in applications and I would like the interface to do this to be consistent across all language families. To accomplish this, a Paketo buildpack language family should follow these guidelines.

- Users should be able to enable or disable remote debugging at run time by using the flag `$BPL_DEBUG_ENABLED`. When true, remote debugging is enabled. When false, it's disabled.
- If a language run time...
  - Includes support for remote debugging natively, and does not require any additional software, a build-time flag should not be required. The support will always be present, including any exec.d binaries to enable the functionality.
  - Does not include support for remote debugging natively and requires additional software to be installed by the buildpack then the buildpack should use the flag `$BP_DEBUG_ENABLED` to control if the software is included. When the flag is present and true, software is enabled. If the flag is absent or set to a non-true value, the additional software should not be included in the image.
- If the language run time remote debugging support listens on a port and that port is configurable, then the buildpack should support a `$BPL_DEBUG_PORT` which allows the user to change the port on which the remote debugger listens.
- If the language run time remote debugging supports the concept of suspending execution until a remote debugger can be attached, then the buildpack should support a `$BPL_DEBUG_SUSPEND` flag. When the value is true, the buildpack should configure the remote debugging support to suspend and wait for a remote debugger connection. When false, it should not wait and the application should start like normal.
- If a buildpack exposes other options to configure remote debugging support, they should be exposed under `$BP_DEBUG_*` for build time options and `$BPL_DEBUG_*` for run time options.

## Rationale and Alternatives

- Not have a standard UI and potentially have different ways for remote debugging to be configured.

## Implementation

The implementation of this RFC will vary from language family to language family. The Detailed Explanation section above specifies the interface that each language family should implement to be compatible with this RFC and provide a consistent user experience.

## Prior Art

The Java buildpacks supports remote debugging in the manner defined above.

## Unresolved Questions and Bikeshedding

Are there other standard debug configuration options that we should list in this RFC?
