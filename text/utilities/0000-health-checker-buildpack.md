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

### Example

A user can then utilize the health checker like this:

1. For a Spring Boot app, run `pack build apps/maven -p target/demo-0.0.1-SNAPSHOT.jar -b paketo-buildpacks/java -b docker.io/paketo-buildpacks/health-checker -e BP_HEALTH_CHECKER_ENABLED=true -e BP_HEALTH_CHECKER_THC_ARGS='8080 /actuator/health'` (it won't be necessary to include the `-b` arguments once the buildpack has been integrated with language family buildpacks). You'll see output like this at the end. It's installing the health checker and setting a process type.

    ```
    Paketo Health Checker Buildpack vDEVELOPMENT
      https://github.com/paketo-buildpacks/health-checker
      Build Configuration:
        $BP_HEALTH_CHECKER_DEPENDENCY  thc                    which health checker to contribute
        $BP_HEALTH_CHECKER_ENABLED     true                   contributes a health checker if enabled
        $BP_HEALTH_CHECKER_THC_ARGS    8080 /actuator/health  arguments passed to tiny-health-checker, if used
      Tiny Health Checker 0.4.0: Contributing to layer
        Downloading from https://github.com/dmikusa-pivotal/tiny-health-checker/releases/download/v0.4.0/thc-x86_64-unknown-linux-musl
        Verifying checksum
        Copying from /tmp/ce75bb97209981e03bf7e8aa52e2bfab78a50a44c7ed1787f4ace212711d61e5/thc-x86_64-unknown-linux-musl to /layers/paketo-buildpacks_health-checker/thc/bin
      Process types:
    health-check: thc 8080 /actuator/health (direct)
    ```

2. You can run this with `docker run --health-cmd '/cnb/process/health-check' --health-interval 5s --health-timeout 2s -it apps/maven`. You could call the health check binary directly, but as you can have different health check dependencies that get installed by the buildpack, using the process type gives you more generic way to call the health check. It also allows for the image to bake in the health check arguments, rather than require the operator to set them. Plus, an operator could always call the binary directly if they wanted.

## Prior Art

None

## Unresolved Questions and Bikeshedding

None
