# Establishing an Emeritus Status

## Summary

The current governance rules outline roles for Contributors, Maintainers, and
Steering Committee members. As the Paketo project has grown and evolved,
contributors, maintainers, and steering committee members have come and gone.
While the current governance rules do outline how those folks might resign or
be removed from their positions, we'd like to establish a third option,
retirement. In the case that a member of one of these teams is found to have
retired from the project, they will be  an emeritus position at their
current role title.

## Motivation

We'd like a way to prune the set of folks with elevated permissions on the
project while still acknowledging the work done by these individuals. We can
remove inactive individuals with the current governance rules, but we'd also
like to recognize their contributions to the project.

## Detailed Explanation

This RFC will function as an addendum to [RFC 0002](./0002-governance.md). For
each role defined in that RFC, we will establish a retirement clause stating
that individuals may retire and accept an emeritus title at their current role
title for any subteam. Functionally, the emeritus title is purely honorific and
imbues the holder with no voting status or permissions for that subteam.

## Rationale and Alternatives

We could keep the current rules and provide no emeritus title.

## Implementation

A subteam contributor or maintainer, or steering committee member can retire by
sending notice to either a subteam maintainer, or a steering committee member.

Alternatively, a contributor or maintainer may be retired by a supermajority
vote from the subteam maintainers. This is similar to a vote to remove that
contributor or maintainer, but also confers the retiree with the emeritus
title. Steering committee members can also be retired, but with a
supermajority vote from the existing steering committee membership.

Once retired, the retiree will be granted with an emeritus title. They will
also be removed from their current role in GitHub teams and their new title
will be recorded in the [teams
roster](https://github.com/paketo-buildpacks/community/blob/main/TEAMS.md) on
the community repository.
