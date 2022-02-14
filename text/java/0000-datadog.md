# Datadog Support

## Summary

The [Paketo Java Buildpack](https://github.com/paketo-buildpacks/java) presently supports the APM tools Google Stackdriver and Azure Application Insights. This RFC proposes we add support for Datadog as well.

## Motivation

Datadog is a popular APM tool and monitoring platform. For Java applications, there was an [initial buildpack which instrumented applications with the Agent](https://github.com/DataDog/datadog-trace-paketo-buildpack), however, this is no longer being maintained. This initial buildpack proved that there is interest for Datadog support & this RFC proposes that we add an official Paketo buildpack.

## Detailed Explanation

This RFC proposes the following changes:

- Create a new buildpack, `paketo-buildpacks/datadog`
- The buildpack will install the Datadog Agent & software required to report metrics to Datadog
- The buildpack will adjust the JVM arguments to enable the Datadog agent
- The initial target is for this buildpack to work with the JVM, however, it will be implemented in a way that integration with other language families is also possible similar to Google Stack Driver and Azure App Insights.

## Rationale and Alternatives

Adds easy support for another popular APM tool/platform. We could not add the buildpack and then users would be left to configure this integration manually, which is not as nice of a user experience.

## Implementation

1. Create a new repo under `paketo-buildpacks/datadog`
2. Set owner as Paketo Java subteam
3. Push a skeleton project using libcnb/libpak
4. Implement the buildpack following the logic describes [here](https://github.com/DataDog/datadog-trace-paketo-buildpack) (Apache 2 license)
5. Update dependencies
6. Add standard set of CI jobs
7. Document usage
8. Publish initial release

## Prior Art

- Google Stack Driver
- Azure Application Insights

## Unresolved Questions and Bikeshedding

- None
