# Define an Image & Dependency Retention Policy for Paketo Images

## Summary

At the moment, the Paketo Project is maintaining images (buildpack, builder, stack, etc..) and hosted dependencies since the beginning of the project. This RFC proposes that we define an image and dependency retention policy that would allow the project to delete old images and dependencies.

## Motivation

Multiple reasons:

1. It is impractical from a cost and resources perspective for the project to maintain all images and dependencies throughout the history of time. Time continues on infinitely, and eventually enough resources will accumulate to where this becomes a burden to the project.
2. It is highly unlikely that images going back to the beginning of the project are still usable. Many buildpacks reference external dependencies and those dependencies may no longer exist.
3. Older stacks, buildpacks, builder images and hosted dependencies very likely are full of vulnerable software and should no longer be used.
4. If users have requirements to retain images for longer periods of time, they can relocate them to their own container image registry before the image retention policy expires the image. Older dependencies can be relocated or users can package up a buildpack image that include the dependencies, again, before the retention policy expires.

## Detailed Explanation

This RFC proposes that we retain all images and hosted dependencies referenced by our images published by the project for at least two year.

Edge cases:

- If the latest image is older than two years, the project will retain that image until a newer version of the image is published or until the sub-team publishing the image officially retires that project. Images for retired projects will be retained for at least one year from the date the project is retired.
- Existing images that are older than two years at the time this RFC is approved will be given a 120 day grace period and then deleted.
- The project may opt to retain any image for longer periods of time at it's discretion, but does not have any obligation to do so.

An announcment will be made through Slack and the project Blog so that users can prepare for this change.

The approval of a retention policy will not extend the duration of time that we continue publishing images to GCR. Usage of GCR has been deprecated with Paketo buildpacks since [RFC 0015 was accepted](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0015-dockerhub-distribution.md). RFC 0015 and the work around it will determine when the project stops using GCR.

## Rationale and Alternatives

- Do nothing. Images and dependencies will accumulate. It will sap project resources.
- Implement a different strategy. Perhaps based on user access patterns, like we can delete images that have not had a pull for more than 30 days. The benefit of a limit is that it's predictable and easy to implement. It makes it easy for users to understand.

## Implementation

The preferrable implementation would be to use configuration through the registry to assign image retention policies. It does not appear that Docker Hub or GCR have configurable image retention policies. If someone knows of a way, this would be the preferred implementation.

Failing that. We will need to configure a daily CI job to run a tool that scans all images and enforces the policy. This should be implemented at the project level, so that individual teams do not need to each enforce this.

This should not require creating a custom tool, as there are some existing tools that we could use in CI.

- [https://github.com/GoogleCloudPlatform/gcr-cleaner](https://github.com/marekaf/gcr-lifecycle-policy)
- [https://github.com/marekaf/gcr-lifecycle-policy](https://github.com/marekaf/gcr-lifecycle-policy)

The specific tool selected can vary and will be an implementation detail that is intentionally left outside of the scope of this RFC.

Once an image is deleted, any hosted dependencies that were referenced by the image which are no longer used by images that are still within the retention policy may be deleted. For example, if buildpack 1.1.1 uses dependency 2.2.2 and no other buildpacks still within the retention policy (i.e. less than 2 years old) referenece dependency 2.2.2 then the project may delete dependency 2.2.2. from it's hosting. This does not apply to externally hosted dependencies as hosting of those dependencies is outside the project. External hosting can follow its own separate policy.

## Prior Art

None. We have been retaining images and dependencies back to the projects beginning.

## Unresolved Questions and Bikeshedding

None