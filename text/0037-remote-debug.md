# Remote Debug

## Summary

The Java buildpack presently supports enabling remote debugging for applications. More buildpacks are looking to enable this functionality. It would be helpful to have a consistent set of environment variables used for enabling remote connections.

## Motivation

The main driver for this is to provide a cohesive experience to Paketo users. It would allow them to use the same environment variables to enable remote debugging across multiple language families.

## Detailed Explanation

As a Paketo user, I want to be able to enable debug support in applications and I would like the interface to do this to be consistent across all language families. To accomplish this, a Paketo buildpack language family should follow these guidelines.

- Users should be able to enable or disable remote debugging at runtime by using the flag `$BPL_DEBUG_ENABLED`. When true, remote debugging is enabled. When false, it's disabled.
- If a language runtime...
  - Includes support for remote debugging natively, and does not require any additional software, a build-time flag should not be required. The support will always be present, including any exec.d binaries to enable the functionality.
  - Does not include support for remote debugging natively and requires additional software to be installed by the buildpack then the buildpack should use the flag `$BP_DEBUG_ENABLED` to control if the software is included. When the flag is present and true, software is enabled. If the flag is absent or set to a non-true value, the additional software should not be included in the image.
- If the language runtime remote debugging support listens on a port and that port is configurable, then the buildpack should support a `$BPL_DEBUG_PORT` which allows the user to change the port on which the remote debugger listens.
- If the language runtime remote debugging supports the concept of suspending execution until a remote debugger can be attached, then the buildpack should support a `$BPL_DEBUG_SUSPEND` flag. When the value is true, the buildpack should configure the remote debugging support to suspend and wait for a remote debugger connection. When false, it should not wait and the application should start like normal.
- If a buildpack exposes other options to configure remote debugging support, they should be exposed under `$BP_DEBUG_*` for build time options and `$BPL_DEBUG_*` for runtime options.

### Debug Examples

```bash
pack build -e BP_DEBUG_ENABLED=true ...
```

This flag is only required at build time if the target language runtime requires additional dependencies to enable remote debugging. For example, Python requires additional libraries be installed. Languages like Java and Node.js that include remote debug support within the runtime do not require `BP_DEBUG_ENABLED` to be set. If `BP_DEBUG_ENABLE` is set for a buildpack that does not require it, the variable should be permitted and ignored.

```bash
docker run -e BPL_DEBUG_ENABLED=true -p 8000:8000 ...
```

This would enable remote debugging and open port 8000 (presumably 8000 is the default port for the remote debugger).

```bash
docker run -e BPL_DEBUG_ENABLED=false ...
```

Without rebuilding the image, setting the env variable to false or removing it altogether would disable remote debugging.

```bash
docker run -e BPL_DEBUG_ENABLED=true -e BPL_DEBUG_PORT=5000 -p 5000:5000 ...
```

Without rebuilding the image, setting the env variable to true and adding `BPL_DEBUG_PORT=5000` enables remote debugging on port 5000 instead of the default port. Similarly, adding `BPL_DEBUG_SUSPEND=true` would change the behavior of the remote debugger, making it suspend until a client debugger is connected.

## Rationale and Alternatives

- Use multiple process types to enable/disable remote debugging. This approach would be fine for simple cases, but it's unclear how certain situations would be handled like multiple process types, buildpacks that use Procfile, or apps where multiple buildpacks can contribute process types.

## Implementation

The implementation of this RFC will vary from language family to language family. The Detailed Explanation section above specifies the interface that each language family should implement to be compatible with this RFC and provide a consistent user experience.

## Prior Art

The Java buildpacks supports remote debugging in the manner defined above.

## Unresolved Questions and Bikeshedding

None
