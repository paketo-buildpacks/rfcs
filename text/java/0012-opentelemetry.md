# OpenTelemetry Support

## Summary

The [Paketo Java Buildpack](https://github.com/paketo-buildpacks/java) currently supports the APM tools Google Stackdriver, Azure Application Insights, and DataDog. This RFC proposes we add support for the open-source OpenTelemetry tool as well.

## Motivation

OpenTelemetry has quickly became a standard for instrumenting, collecting, and exporting telemetry data. It's adopted and supported by industry leaders in the observability space. For Java applications, an OpenTelemetry Java Agent is available for instrumenting the code and exporting traces, metrics, and logs.

## Detailed Explanation

This RFC proposes the following changes:

- Create a new buildpack, `paketo-buildpacks/opentelemetry`.
- The buildpack will install the OpenTelemetry Agent, which includes everything needed to instrument and export telemetry data.
- The buildpack will adjust the JVM arguments to enable the OpenTelemetry Agent.
- Users would configure the OpenTelemetry Agent using the [standard environment variables](https://opentelemetry.io/docs/instrumentation/java/automatic/agent-config/#configuring-the-agent) provided by the OpenTelemetry project itself.
- The initial target is for this buildpack to work with the JVM. However, support for other language families is possible in the future.

## Rationale and Alternatives

The goal is to add easy support for using an open-source and industry-standard for handling telemetry in Java applications. Observability is a critical property of any cloud native application, and this buildpack would make it straightforward to instrument and collect telemetry from containerized workloads. Without the buildpack, it's still possible to include the agent manually, but the user experience would not be that great.

## Implementation

1. Create a new repo under `paketo-buildpacks/opentelemetry`
2. Set owner as Paketo Java subteam
3. Push a skeleton project using libcnb/libpak
4. Implement the buildpack based on the prototype [here](https://github.com/ThomasVitale/buildpacks-opentelemetry) (Apache 2 license)
5. Update dependencies
6. Add standard set of CI jobs
7. Document usage
8. Publish initial release

## Prior Art

- Azure Application Insights
- Google Stack Driver
- Datadog

## Unresolved Questions and Bikeshedding

- None
