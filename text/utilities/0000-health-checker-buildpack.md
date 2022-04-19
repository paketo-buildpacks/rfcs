# Health Checker Support

## Summary

Introduce a Health Checker buildpack. This buildpack will provide access to one or more health checkers, where a health checker is a small binary that will be installed into the container image for the purpose of validating the health of the runnning image.

By default, we'll provide a tiny HTTP health checker which can be used to probe a port and path. An HTTP 200 OK response returns exit code 0 and a non-2xx response returns 1.

The Health Checker buildpack would be maintained by the existing [Utilities team](https://github.com/orgs/paketo-buildpacks/teams/utilities). It uses libpak & libcnb.

## Motivation

When running buildpack generated images on Kubernetes, HTTP-based health checking is provided by the platform. When running your buildpack generated images with Docker or Docker Compose, there is no option for HTTP-based health checks. It requires a binary in the image to perform the HTTP operation. This is typically `curl` or `wget`, however, the Paketo tiny and base images do not include these binaries.

Having a buildpack that installs a health checker allows for HTTP-based health checks when running on Docker. In addition, it could allow for other types of health checkers for example if your application does not use HTTP.

## Detailed Explanation

1. A health checker buildpack has been developed. It will be contributed to Paketo.
   1. By default, no health checker will be installed by the buildpack.
   2. If a user sets `BP_HEALTH_CHECKER_ENABLED=true` then the buildpack will detect and contribute a health check binary to the `$PATH`.
   3. A process type of `health-check` will be contributed with the command to run the health checker. This may be invoked by the user rather than needing the full command.

## Rationale and Alternatives

1. A user can create a custom stack and include a tool like `curl` or `wget`. This is a lot of additional work, plus `curl` and `wget` are overkill for a simple HTTP health check. To reduce footprint, they are not recommended.

## Implementation

The new Health Checker buildpack will participate if all the following conditions are met

* A user sets `BP_HEALTH_CHECKER_ENABLED=true`

When conditions are met, the buildpack will do the following:

* Contributes a health checker to a layer marked `launch` with command on `$PATH`
* Contributes a process type called `health-check` which will execute the installed health checker.

The Health Checker buildpack will optionally be added to the language family buildpacks that wish to include support for it. The primary targets will be the Java and Rust buildpacks.

## Prior Art

None

## Unresolved Questions and Bikeshedding

None
