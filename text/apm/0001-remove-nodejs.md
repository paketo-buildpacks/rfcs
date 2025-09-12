# Remove Node.js Support from Application Monitoring Tools Buildpacks

## Summary

This proposal is to remove the Node.js support from the Application Monitoring Tools buildpacks.

## Motivation

When the APM Tools Buildpacks were contributed to Paketo, they came with Node.js support. On the surface, this sounds great. More support for different languages. This is not a bad thing, however, the way that these buildpacks implement support for Node.js is not consistent with what Node.js users expect or what the APM tool companies are recommending. Consequently, I do not believe anyone uses it.

As evidence of that, I have intentionally not updated any of the Node.js tools for these buildpacks for close to half a year and no one has reached out about it or complained about them being out of date. Including the companies that create these tools.

I have also reached out to some folks on the Node.js maintainers team to get opinions and have not found any supporting evidence of users or anyone that favors the approach of the Node.js implementation in the APM Tools buildpacks.

## Detailed Explanation

The Node.js implementation in the APM Tools buildpacks has two flaws:

1. It downloads the Node.js tools in the buildpack. This is unexpected as a Node.js user. Node.js users expect things to be downloaded by the package manager (`npm`, `yarn`, etc...).
2. It then modifies the users code to inject and require the dependencies. Using `require` is outdated in many JavaScript/TypeScript projects and having a buildpack that modifies user code is a mistake. Buildpacks should not modify user code.

## Rationale and Alternatives

Rationale is explained in the motivation section.

I do not believe there are alternatives from the buildpacks perspective, because it is not expected for buildpacks to be injecting dependencies or modifying code. Node.js does not have external monitoring tools, like the JVM has agents, so there is not to my knowledge a way that buildpacks could do this without adding dependencies and modifying code. If anyone has other ideas, we could explore them though.

## Implementation

Remove the Node.js support from the following buildpacks:

- `paketo-buildpacks/appdynamics`
- `paketo-buildpacks/elastic-apm`
- `paketo-buildpacks/new-relic`
- `paketo-buildpacks/google-stackdriver`
- `paketo-buildpacks/datadog`
- `paketo-buildpacks/azure-application-insights`

The exception is `paketo-buildpacks/dynatrace`, for which we will not remove any support. Dynatrace support works differently, through a single agent that is injected outside of the Node.js runtime. Its implementation does not require adding Node.js dependencies or modifying code.

After removing, we will post an announcement on the Paketo Buildpacks Blog. Users may continue using previous versions of the buildpack if they need support or fork from the commit, which we'll list in the buildpack, and continue maintaining on their own.

## Prior Art

None

## Unresolved Questions and Bikeshedding

None
