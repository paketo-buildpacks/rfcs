# Rename Buildpacks

## Summary

At present, the Paketo buildpacks follow a naming convention of `Paketo <technology> Buildpack`. This proposal is to change the naming convention and all existing buildpacks to follow the pattern `Paketo Buildpack for <technology>`.

## Motivation

We are using various product and project names in the names of our buildpacks, but these names are trademarks of the project owners. While some of the relevant trademark owners are relaxed, others have usage guidelines that prohibit our naming approach.

For example, the [Apache guidelines state](https://www.apache.org/foundation/marks/#products) `In general you may not use ASF trademarks in any software product branding. However in very specific situations you may use the Powered By naming form for software products.`.

This is further complicated as you expand into support for commercial products which have non-OSS licenses. For example, the [Dynatrace guidelines](https://assets.dynatrace.com/global/legal/dynatrace-trademark-usage-guidelines-2021-08.pdf) state that their trademarks `must not be applied to the products or services of any other company.` However, the guidelines allow: `You may indicate the relationship of your products and services to Dynatrace products or services by using an accurate referential phrase in connection with your product or service, such as “for use with,” or “compatible with,” as long as your usage does not create the impression of any partnership with or endorsement by Dynatrace, and as long as your usage does not create the possibility of confusion as to the source of the product or service.`.

The recommendation we have received is to use the naming convention `Paketo Buildpack for <technology>` which more clearly separates our project work from the technology with which we are integrating.

## Detailed Explanation

See [Motivation](#motivation) and [Implementation](#implementation) below.

## Rationale and Alternatives

We could continue to use our existing naming schema. 

The information in this document was contributed to us by VMware's OSS/Legal team while going through their process to [contribute APM Tooling buildpacks](https://github.com/paketo-buildpacks/rfcs/pull/222). It does not represent a mandate or requirement to change.

## Implementation

The following actions will need to be taken:

1. For each buildpack, update README.md & buildpack.toml changing the buildpack name. This plan does not change buildpack IDs, Github repository names or image registry coordinates. Because buildpacks only use the name for astetic purposes, we do not anticipate this change to break users.

2. For the Paketo Website, we'll need to update documentation that references buildpack names.

3. For the Paketo Samples, we'll need to update documentation that references buildpack names.

4. Some buildpacks may have unit/integration tests which reference the names of buildpacks. For example, if a test is attempting confirm a buildpack has run, it may look for the buildpack name in the build logs to confirm.

## Prior Art

- None

## Unresolved Questions and Bikeshedding

- None
