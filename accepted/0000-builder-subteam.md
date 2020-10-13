# Builders Subteam

## Summary

The Builders are being separated out of the set of responsiblities of the Core
Dependencies team. This means that a new subteam will need to be created to
maintain the repositories under this responsibility.

## Motivation

The existing Core Dependencies team is wishing to focus more directly on stacks
and less on builders which a more directly a "buildpack concern". Having a set
of maintainers and contributors from the existing buildpack subteams would help
to better align this responsibility with those folks concerned.

## Detailed Explanation

A new Builders subteam will take over maintenance of the existing [builder
repository](https://github.com/paketo-buildpacks/builder) and any new
repositories created under RFCs declared within that repo.

As an initial proposal, there will be 2 maintainers, one from the Java team,
and one from the other teams (@ekcasey and @floragj). All other individuals in
either the maintainers or contributors team for each language family will be
included as contributors for this new subteam.

## Rationale and Alternatives

We could choose to maintain the status quo.

## Implementation

1. A "Builders" team should be created in the [paketo-buildpacks GitHub
   org](https://github.com/orgs/paketo-buildpacks/teams) with the designated
   maintainers.
1. All other maintainers or contributors for language family teams should be
   added as contributors.
1. The "Builders" team should be granted maintainer and contributor permissions
   to manage the [builder
   repository](https://github.com/paketo-buildpacks/builder).

## Unresolved Questions and Bikeshedding

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
