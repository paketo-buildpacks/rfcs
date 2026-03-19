# Following the bienial Ubuntu LTS release cycle

## Summary

Every other year, Ubuntu releases a new Long Term Support (LTS) version. This proposal is to ensure that Paketo continues to provide the latest Ubuntu-based stackroot file system for our users by producing a new set of builders based on the latest LTS release.
This comprises to provide build and run images, making sure the relevant buildpacks support the new LTS and providing the corresponding builders.

In particular, since April 2024, Ubuntu released 24.04 Ubuntu Noble Numbat as the successor of 22.04 Ubuntu Jammy Jellyfish. Work has begun to provide build and run images for the Noble Numbat release. However, not all buildpacks have confirmed support and no builders have been released yet.

## Motivation

Users of Paketo rely on us to provide an up-to-date root file system for their applications. This includes the latest security patches and software updates. While Ubuntu LTS releases are supported for 5 years, it is important to provide the latest LTS release to our users as soon as possible to ensure they can benefit from the latest features and security updates. This also provides a longer period of time for users to transition from one release to the next.

## Detailed Explanation

In late April of every even year, Ubuntu releases a new LTS version. Once the new LTS version is released, the Stacks team will begin work on providing the new build and run images. Once build and run images are available, the Builders team will begin work on providing the corresponding builders. Once the buildpackless builders are available, the individual buildpack teams will begin to evaluate and test their buildpacks on the new builders and work on fixes or mitigations should they be needed. Once all buildpacks have been confirmed to work on the new builders, the Builders team releases the buildpackfull builders.

## Rationale and Alternatives

We could opt to adopt LTS's less frequently or additionally adopt the releases in between LTS releases. However, the former would result in users not having access to the latest features and security updates, while the latter would result in a significant increase in the number of builders we need to maintain.

## Implementation

1. Beginning of April of every even year, the Steering team will create the necessary repositories for stacks and builders. 
2. During the Ubuntu LTS Release Candidate phase or latest once an official release is available, the Stacks team will begin work on providing the new build and run images.
3. Once the build and run images are available, the Builders team will begin work on providing the corresponding builders.
4. Once the buildpackless builders are available, the individual buildpack teams will begin to evaluate and test their buildpacks on the new builders.
5. Once all buildpacks have been confirmed to work on the new builders, the Builders team releases the buildpackfull builders.
6. We'll announce the availability of the new builders to the community.

## Prior Art

* [RFC 0004: Jammy Jellyfish](./stacks/0004-jammy-jellyfish.md)

## Unresolved Questions and Bikeshedding

* What if not all buildpack teams have the capacity to test their buildpacks on the new builders before the release of the buildpackfull builders?
