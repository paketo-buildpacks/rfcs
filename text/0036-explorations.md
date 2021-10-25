# Explorations Repository

## Summary

In the process of developing buildpacks, Paketo maintainers and contributors
perform technical explorations. These sometimes lead to new
RFCs/buildpacks/features. Up to this point, artifacts generated from
explorations have been checked into a variety of repos. There is no central
resource for users, contributors, and maintainers to see what's being explored
for the future of Paketo. This RFC proposes a repository
`paketo-community/explorations` wherein artifacts like decision records, sample
apps, and prototypes can be stored in a centralized place.

## Motivation

Paketo strives to make decisions out in the open as much as possible. Often,
the results of contributors' technical explorations inform our decisions about
what to implement and how. Some past explorations include:
- [Tilt + Paketo buildpacks](https://github.com/ryanmoran/explorations/blob/fc8866768fc3116857f87f488baf864bc7c2557f/0002-tilt/README.md)
- investigation of Poetry support in the Python buildpack
- [Rapid feedback loops with Paketo buildpacks](https://github.com/paketo-buildpacks/rapid-feedback-loops)

The above examples show 3 approaches the project has taken to documenting
explorations in the past: in a repo owned by an individual contributor, in
documents not stored in Github, in a repo inside the `paketo-buildpacks` org.
The first two approaches lack transparency and discoverability. How can new
users uncover these contributions without prior knowledge or a hint from
someone in-the-know? The last is an example of a new repo in
`paketo-buildpacks` that falls outside of the org's governance structure and is
likely to become inactive in a matter of months. A proliferation of repos like
that one would clutter the org.

`paketo-community` is the established Paketo org for "the testing of new
technologies or the development of buildpacks in an environment that is more
flexible than that of the core Paketo" (see [RFC
0008](https://github.com/paketo-buildpacks/rfcs/blob/32253f0099d3bc3affde2f48a802b70aabc76fa5/text/0008-paketo-community.md)).
A repo in that org that centrally locates exploratory work will make this work
visible to community members, will allow the work to be easily referenced in
RFCs and other project-wide conversations, and will open a new avenue for
contributorship to the project. Users with large feature requests can
contribute explorations if they have done some legwork to examine
how their request might be implemented.

Moreover, issues on the repo can be used to track upcoming/in progress lines of
investigation. This makes the project's future directions more visible, as
well.

## Detailed Explanation

See implementation.

## Rationale and Alternatives

1. Do nothing. Allow explorations to proliferate wherever makes sense for
   contributors.
   Drawbacks:
       - See Motivation section
2. Don't create a new repo for explorations, but forbid the creation of repos
   in `paketo-buildpacks` that fall outside of project governance (like
   `paketo-buildpacks/rapid-feedback-loops`).
   Drawbacks:
       - Doesn't address the visibility of explorations concern.
3. Use another platform to store information about explorations (e.g. Slack channel, Google drive)
   Drawbacks:
       - As we saw with the desired for centralization of Paketo RFCs into
         `paketo-buildapcks/rfcs`, decentralized decision records make it
         harder for community members to figure out the current state of the
         project.

## Implementation

This RFC proposes the creation of an `explorations` repo in `paketo-community`.
Its maintainers will be the Content team, since contributions to the repo are
mostly intended to educate/inform members of the community.

The `main` branch of the repo should be protected, as with our other repos. New
explorations should be added in their own directories via pull request.  It is
the responsibility of Content maintainers to ensure that the content added in a
PR is intelligible and useful as a shared record of exploratory work. The
inclusion of clear READMEs in exploration directories is a good place to start.

## Prior Art

- [Github discussion](https://github.com/paketo-buildpacks/feedback/discussions/20)

## Unresolved Questions and Bikeshedding
- What should we name the repo?

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
