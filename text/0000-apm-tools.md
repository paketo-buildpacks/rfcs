# Contribute APM Tools Buildpacks

## Summary

The VMware Tanzu team has maintained eight APM tools Cloud-Native buildpacks for a number of years as proprietary buildpacks. VMware would like to contribute these buildpacks to the Paketo project.

The list of buildpacks to contribute is:

- Apache Skywalking
- AppDynamics
- Aternity
- Dynatrace
- Elastic APM
- JProfiler
- New Relic
- YourKit

Each of these buildpacks includes support for Java, some also include support for Node.js, and a few include support for PHP. They are all written in such a way that adding additional language families is possible.

The buildpacks to contribute are written in Go and utilize the libcnb and libpak libraries. They all use pipeline-builder for managing Github Actions. 

Each buildpack functions in a similar fashion. It will install any required dependencies (agents, libraries, etc..). It may install a runtime exec.d helper to application configuration settings at runtime (usually from bindings). It will contribute any modifications to runtime configuration or start commands to ensure that the agent is loaded when the application launches. Details for each buildpack [can be found here](https://docs.vmware.com/en/VMware-Tanzu-Buildpacks/services/tanzu-buildpacks/GUID-partner-integrations-partner-integration-buildpacks.html).

## Motivation

VMware is vested in the buildpacks community and believes that a great way to grow the buildpacks community is to expand the set of available buildpacks. There have been requests for additional APM tooling support from the community and this will fill that need.

## Detailed Explanation

This RFC proposes the following changes:

1. Create a new Paketo sub-team called "APM Tools". This team will be the owner for all eight of these buildpacks, as well as the existing APM related buildpacks: Azure Application Insights, Google Stackdriver, and Datadog.
2. Since the APM tooling buildpacks function across language families, the "APM Tools" sub-team will be seeded with one maintainer from each language family team. This is to ensure that there is representation  and ownership from each language family.
3. Create eight new repositories, one for each buildpack to be contributed. The APM Tools team will own these repositories. The repository names will follow the pattern `Paketo <technology> Buildpack`, ex: `Paketo Apache Skywalking Buildpack`, as is the existing convention. GitHub repository names will be the name of the technology, ex: `apache-skywalking`. Buildpack ID and image registry names will match the GitHub repository name, ex: `docker.io/paketobuildpacks/apache-skywalking`.
4. VMware will submit a PR to each repository with the code for each buildpack. The PR will include all source code, as well as Github Actions, for the project. Use of a PR is intentional as it will effectively truncate the VMware Git history for each repository.
5. Cut releases
6. Contribute documentation. This will involve creating a new section dedicated for APM tools. Existing language families can then link to this shared section.
7. Contribute samples. To not dramatically grow the number of samples, the plan is to take a single sample for each language family and reuse that by providing instructions in the README.md on how to use that application with each APM tool.

## Rationale and Alternatives

1. Develop clean-room implementations of APM tooling buildpacks for Paketo. This is costly in terms of time and due to this additional time, could result in users unable to use Paketo buildpacks because of missing support.
2. Document manual steps for users to enable APM tooling in their applications. This is manual work each user would need to do and is not a good way to grow the community.

## Implementation

The plan is outlined in [Detailed Explanation](#detailed-explanation) above.

## Prior Art

There are existing APM Tools buildpacks:

- Azure Application Insights
- Google Stack Driver
- Datadog

## Unresolved Questions and Bikeshedding

- None