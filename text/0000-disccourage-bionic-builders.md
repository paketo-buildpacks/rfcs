# Users should be discouraged of still using bionic builders

## Summary

User might still be using `bionic` based builders (e.g. `paketobuildpacks/builder:base`) without realizing that it reached end of life. The user should be made aware that this builder is not maintained anymore.

## Motivation

Since the names of the `bionic` builders have no `bionic` in the name (e.g. `paketobuildpacks/builder:base`), it is not unlikely that users might not be aware that they are using a stack thit is end of life for a couple of month.

So we should make the users aware about this fact, so that they can decide if they want to switch to `jammy` or keep using `bionic`.

Since the switch to the `jammy` builder might need effort, it is probably benefical to point the users already in that direction.

## Detailed Explanation

We could add a new buildpack to the builders that will cause every build to fail unless the environment variable `BP_USE_DEPRECATED_STACK` is provided. With that, we would force the user to either move to a maintained builder or to make the decision to keep using the builder by adding this environment variable.

## Rationale and Alternatives

* The naming scheme of the `bionic` builders somehow implies that the builder keeps up to date. So it might even be risky to keep users use a stack after end of life.
* We could also remove the tags to make it unconvenient to keep using the builders. If there is a necessity, the builder could still be used by digest.
* We could only warn when using the builder, but there would be a risk of this warning not being read.

## Implementation

{{Give a high-level overview of implementation requirements and concerns. Be specific about areas of code that need to change, and what their potential effects are. Discuss which repositories and sub-components will be affected, and what its overall code effect might be.}}

{{THIS SECTION IS REQUIRED FOR RATIFICATION -- you can skip it if you don't know the technical details when first submitting the proposal, but it must be there before it's accepted.}}

## Prior Art

This is special because the names for the `bionic` builders (`paketobuildpacks/builder:tiny`, `paketobuildpacks/builder:base`, `paketobuildpacks/builder:full`) appear to be agnostic. The `jammy` builders do not have the same problem anymore.

## Unresolved Questions and Bikeshedding

{{Write about any arbitrary decisions that need to be made (syntax, colors, formatting, minor UX decisions), and any questions for the proposal that have not been answered.}}

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
