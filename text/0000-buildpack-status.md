# Introduce a maintenance status for buildpacks

## Summary

Given the finite capacity of the maintainer teams, we should introduce a distinction between the different levels of maintenance individual buildpacks provide.
The proposed levels are:
- **Active Maintenance**: The buildpack is actively maintained and updated by the maintainers. Feature requests and bug reports are actively worked on. The maintainers have capacity for coordinated cross project work.
- **Security Maintenance**: The buildpack is maintained and updated by the maintainers, but the focus is on critical bugs and project hygene like dependency updates. The maintainers might have limited capacity for cross project work.
- **Out of maintenance**: The buildpack is not actively maintained by the maintainers. The maintainers might still accept PRs and bug reports, but the response time is not guaranteed. The maintainers have no capacity for cross project work.

## Motivation

A couple of maintainers have recently left the project, without others having stepped up to take over their responsibilities. Some of the maintainer teams are down to a single maintainer. This is not good for the project overall and in particular not for the outside perception. At the same time, we should acknowledge that some of the buildpacks might be as finished as software can get and don't need active maintenance anymore. This proposal aims to make the current state of the buildpacks more transparent to the users and to the maintainers themselves. In particular, the remaining maintainers might want to avoid being blocked on important cross project work by buildpacks that are not actively maintained anymore.

## Detailed Explanation

We should define the different levels of maintenance and the expectations that come with them.
I would suggest that the core builder proposed with https://github.com/paketo-buildpacks/rfcs/pull/313 would only accept buildpacks that are actively maintained. That way we can make sure that cross project topics like multi-arch or Ubuntu LTS updates can be addressed in a timely manner. Users can still use the other buildpacks, by specifying them explicitly.

Those buildpacks that get marked **Out of maintenance** should probably either be archived or moved to the paketo-community organization. We should also make sure that the users are aware of the status of the buildpacks. This could be done by adding a badge to the README of the buildpacks.

## Rationale and Alternatives

We could continue as we are, but that will lead to cross project efforts to potentially take indefinitely.

## Implementation

We should document the different levels of maintenance.
We should check with maintainers of the buildpacks if they agree with the proposed level of maintenance.

## Prior Art

None.

## Unresolved Questions and Bikeshedding

- What levels of maintenance should we have? I came up with two different levels of maintenance and one to express that the buildpack is not maintained anymore. I am happy to introduce finer grained levels of maintenance if that is desired.
- What about the buildpacks that are not maintained anymore? Should we archive them or move them to the paketo-community organization?
- What about paketo-community? Do we really need that if we have this tier system? 