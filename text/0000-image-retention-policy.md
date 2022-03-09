# Define an Image Retention Policy for Paketo Images

## Summary

At the moment, the Paketo Project is maintaining images (buildpack, builder, stack, etc..) since the beginning of the project. This RFC proposes that we define an image retention policy that would allow the project to delete old images.

## Motivation

Multiple reasons:

1. It is impractical from a cost and resources perspective for the project to maintain all images throughout the history of time. Time continues on infinitely, and eventually enough resources will accumulate to where this becomes a burden to the project.
2. It is highly unlikely that images going back to the beginning of the project are still usable. Most buildpacks reference external dependencies and those dependencies may no longer exist.
3. Older stacks, buildpacks and builder images very likely are full of vulnerable software and should no longer be used.
4. If users have requirements to retain images for longer periods of time, they can relocate them to their own container image registry before the image retention policy expires the image.

## Detailed Explanation

This RFC proposes that we retain all images published by the project for at least two year.

Edge cases:

- If the latest image is older than two years, the project will retain that image until a newer version of the image is published or until the sub-team publishing the image officially retires that project. Images for retired projects will be retained for at least one year from the date the project is retired.
- Existing images that are older than two years at the time this RFC is approved will be given a 120 day grace period and then deleted.
- The project may opt to retain any image for longer periods of time at it's discretion, but does not have any obligation to do so.

An announcment will be made through Slack and the project Blog so that users can prepare for this change.

The approval of a retention policy will not extend the duration of time that we continue publishing images to GCR. Usage of GCR has been deprecated with Paketo buildpacks since [RFC 0015 was accepted](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0015-dockerhub-distribution.md). RFC 0015 and the work around it will determine when the project stops using GCR.

## Rationale and Alternatives

- Do nothing. Images will accumulate. It will sap project resources.
- Implement a different strategy. Perhaps based on user access patterns, like we can delete images that have not had a pull for more than 30 days. The benefit of a limit is that it's predictable and easy to implement. It makes it easy for users to understand.

## Implementation

The preferrable implementation would be to use configuration through the registry to assign image retention policies. It does not appear that Docker Hub or GCR have configurable image retention policies. If someone knows of a way, this would be the preferred implementation.

Failing that. We will need to configure a daily CI job to run a tool that scans all images and enforces the policy. This should be implemented at the project level, so that individual teams do not need to each enforce this.

This should not require creating a custom tool, as there are some existing tools that we could use in CI.

- [https://github.com/GoogleCloudPlatform/gcr-cleaner](https://github.com/marekaf/gcr-lifecycle-policy)
- [https://github.com/marekaf/gcr-lifecycle-policy](https://github.com/marekaf/gcr-lifecycle-policy)

The specific tool selected can vary and will be an implementation detail that is intentionally left outside of the scope of this RFC.

## Prior Art

None. We have been retaining images back to the projects beginning.

## Unresolved Questions and Bikeshedding

1. Is two years the right retention period? Longer? Shorter? The general idea is that we pick a period of time that minimizes impact to users. We want the time period to be such that at least 99% of users are no longer using these images. We are not strictly looking to minimize costs, but just put an upper bound on what the project needs to support.

2. As part of the GCR migration to Docker Hub, there is the question of do we move older images over to Docker Hub? If so, how many? Should this policy be used to answer that question? For example, if the retention policy is two years, would we then be responsible for moving at least two years worth of images over from GCR to Docker Hub?
