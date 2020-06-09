# Paketo Community

## Summary

The Paketo Community should be a place that trusted community created buildpacks should be hosted. This would provide a consumer of Paketo buildpacks a trusted place to search for extensions to Paketo buildpack functionality.

## Motivation

Having a place for trusted, community created buildpacks allows for effective increased buildpack ecosystem capability without putting newer and unproven buildpacks directly into the core Paketo artifacts.

The Paketo Community will allow for the testing of new technologies or the development of buildpacks in an environment that is more flexible than that of the core Paketo.

A trusted repository of community buildpacks will also allow for a trusted source of buildpacks that solve common yet still relatively niche problems that are not suitable to be added to core Paketo.

## Detailed Explanation

A trusted project is a defined by the following:
- The project must be actively maintained (definition of actively still in the works) (there is also a question around buildpacks that may not need to be actively maintained so some metric on neediness may be important).
- There must be visible automated testing for all repositories that are part of the project.
- The project maintainers must conform to a set of best effort SLOs around patching critical CVEs. (when applicable)

This definition of trusted is meant to alleviate the following problems:
1. There must be a defined system in place to reap abandonware.
1. All repositories must meet some testing standard to be trusted in order to ensure that development within the project does not experience large regressions or introduce buggy code on a regular basis.
1. If a project maintainers are not making a best effort of patching out or updating vulnerable software then the project as a whole is untrustworthy.

The maintainers must also be willing to sign the project over to the Cloud Foundry Foundation and conform to the licensing of the project.

## Implementation

For a new project to be added to the Paketo Community organization, it must conform to the standard of what it means to be a trusted project. Then the maintainers of the project may open a proposal for their project to be added to the Paketo Community organization. If this proposal gets sponsored by at least two maintainers of the Paketo project then the project may be merged into the Paketo Community organization. The responsibility of the maintainers that sponsored the project is to ensure that the project continues to meet the requirements of a trusted project and if it fails to meet that standard to remove it from the Paketo Community organization.

## Future Art

Have a build process that is controlled by the Paketo project that will allow for the compilation to all Paketo and Paketo Community artifacts to ensure the security of the artifacts.

## Prior Art

- [EPEL](https://fedoraproject.org/wiki/EPEL) and [PPA](https://launchpad.net/ubuntu/+ppas)
- The [guarantee](https://fedoraproject.org/wiki/EPEL#Can_I_rely_on_these_packages.3F) the Red Hat gived for EPEL

## Unresolved Questions and Bikeshedding

- Should this organization be called Paketo Community?

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
