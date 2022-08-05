# Graceful Stack Upgrades

## Summary

All Paketo Buildpacks should support graceful stack upgrades between the
current Bionic and Jammy stacks. For most buildpacks, this should not require
any changes, but for some buildpacks, layers created in previous builds that
would normally be reused should be recreated if the stack ID changes.

## Motivation

We have released support for the Jammy stack for a number of buildpacks at this
point. It is an expectation of our users that they be able to gracefully
upgrade the stack underlying their application image. However, some buildpacks
may have produced layers that will no longer behave correctly once the stack
has been modified.

## Detailed Explanation

Buildpacks should consider adding tests that modify the underlying stack
between subsequent builds to confirm that their buildpack handles this
modification correctly. In most cases, this should require no changes to the
buildpack beyond the addition of a new test to assert the modification works as
expected.

For some buildpacks, we will want to introduce code that tracks the stack ID
between builds and recreates layers built with a stack ID that differs from the
current `CNB_STACK_ID` value.

Specifically, buildpacks that install dependencies they control will likely not
need any modification given that their dependencies are mapped back to stacks
through their metadata. Additionally, buildpacks that set a start command will
also likely not need any modification as they rarely produce layers that would
be tied to a specific stack.

The types of buildpacks that will need to be investigated and fixed are likely
to be those buildpacks that perform some sort of installation process, like
`bundle-install` or `composer-install`. In these cases, the maintainers should
investigate whether users are likely to see issues when swapping out stacks,
and modify their buildpacks accordingly.

To ensure that this graceful upgrade will work in all cases, buildpack authors
should consider recreating layers when the previous stack ID was not recorded
on the existing layer. This will result in a one-time penalty rebuild for
applications that contain layers that didn't not record the previous stack ID.
That cost seems like a reasonable tradeoff for correctly built images when the
stack ID changes.

## Rationale and Alternatives

Making the upgrade process as smooth as possible will ensure more users move to
the new stacks.

As an alternative, we could document that modifying the stack ID will require
that users clear any cached layers from prior builds.

## Implementation

Buildpacks will add integration tests that assert that they handle this stack
ID modification correctly.
