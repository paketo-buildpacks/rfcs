# Introduce a maintenance status for buildpacks

## Summary

Given the finite capacity of the maintainer teams, we should establish distinct tiers within the project and clearly document which expectations are attached to the different tiers - both from a perspective of peer maintainers as well as users.
- **Tier 1**: The buildpack is actively maintained and updated by the maintainers. Feature requests and bug reports are actively worked on. The maintainers have capacity for coordinated cross project work.
- **Tier 2**: The buildpack is actively maintained and updated by the maintainers, but the focus is on critical bugs and project hygene like dependency updates. The maintainers might have limited capacity for cross project work.
- **Tier 3**: The buildpack is not maintained anymore. The maintainers will not accept PRs or bug reports. The buildpack might be archived or moved to the paketo-community organization.

## Motivation

A couple of maintainers have recently left the project, without others having stepped up to take over their responsibilities. Some of the maintainer teams are down to a single maintainer. This is not good for the project overall and in particular not for the outside perception. At the same time, we should acknowledge that some of the buildpacks might be as finished as software can get and don't need active maintenance anymore. This proposal aims to make the current state of the buildpacks more transparent to the users and to the maintainers themselves. In particular, the remaining maintainers might want to avoid being blocked on important cross project work by buildpacks that are not actively maintained anymore.

## Detailed Explanation

All repositories in the paketo-buildpacks organization should be assigned to one of the tiers and the assignment should be visible prominently on the repository's README.md as well as maintained as a topic to make the information machine readable.

Tier asignment conditions:
- **Tier 1**: The repository needs at least two maintainers that are actively working on the repository. The maintainers should respond to issues and PRs in a timely manner. The maintainers should also engange with the community via Slack or Github discussions. The maintainers should have capacity for cross project work. The repository should have a documented and frequent release process.
   **Note**: A freshly incubating repository does not immediately have to fulfil all criteria. It has to be clear though that it will reach that level of matirity before a 1.0 release can be created. The incubation status should be mainatined in the README.md and as a topic.
- **Tier 2**: The repository needs at least one maintainer that is actively working on the repository. The maintainers should respond to critical issues and PRs in a timely manner. The maintainers should have capacity for dependency updates and other project hygene tasks. The repository should have a documented release process. It does not have to follow a fixed schedule, but critical updates should be released in a timely manner and it should be clear how to request a release.
- **Tier 3**: The repository is not maintained anymore. The maintainers will not accept PRs or bug reports. The repository might be archived or moved to the paketo-community organization.

Tier assignment consequences:
- **Tier 1**: Maintainers of Tier 1 repositories should transparently manage the work being done and the roadmap for future work. Maintainers of Tier 1 repositories should collaborate on cross project work. This includes, but is not limited to, participating in the RFC process. Commonly used infrastructure like Occam, the buildpack libraries (libpak and packit) and pipeline configuration (pipeline-builder and github-config) and others should align changes with the maintainers of the Tier 1 buildpacks. On the flip side, maintainers of Tier 1 repositories should make sure that their buildpacks are compatible with the latest versions of the common infrastructure. For example they must ensure the buildpacks can be included in the project maintained builders.
- **Tier 2**: Maintainers of Tier 2 repositories should transparently manage the work being done and the roadmap for future work - of course limited to critical fixes and repository hygiene like dependency updates. Tier 2 buildpacks will not be included in the project maintained builders. Tier 2 buildpacks are free to use commonly maintained infrastructure, but they are not guaranteed to be considered when common infrastructure is updated.
- **Tier 3**: The repository is archived or moved to the paketo-community organization.

The Tier assignment is done done by the Paketo Steering Committee in collaboration with the maintainers. Moving from one Tier to another can be done in both directions.

## Rationale and Alternatives

We could continue as we are, but that will lead to cross project efforts to potentially take indefinitely.

## Implementation

We should document the different levels of maintenance.
We should check with maintainers of the buildpacks if they agree with the proposed level of maintenance.

## Prior Art

None.

## Unresolved Questions and Bikeshedding

- What about the buildpacks that are not maintained anymore? Should we archive them or move them to the paketo-community organization?
- What about paketo-community? Do we really need that if we have this tier system? 