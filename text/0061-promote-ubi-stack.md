# Promote ubi stack to paketo-buildpacks

## Summary

Addition of ubi stacks was discussed and approved in
[https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md])https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md).

Initially repositories were added to to paketo-community to reflect that they were under early development. 

The ubi stack has been being built and published since August 2023. Except where it implements
advanced features like multi-arch it uses the common automation, and the team is working to integrate
the advanced features back into the common versions of the automation flows.  

No major updates are planned to the stack, it already implements multi-arch and the only planned updates
are to keep it up to date with newer releases of ubi 8.

There are active maintainers for the stack and no significant issues open in the repo.

The stack is ready to be promoted to paketo-buildpacks.

## Motivation

Addition of ubi stacks was approved in
[https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md])https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md).

Promotion to paketo-buildpacks from paketo-community is the next step towards completing that.

## Detailed Explanation

* Rename https://github.com/paketo-community/ubi-base-stack/ to https://github.com/paketo-community/ubi8-base-stack/
* Rename all references to paketo-community/ubi-base-stack to paketo-community/ubi8-base-stack across the Paketo projects (go project references and buildpack references) 
* Rename all references to paketocommunity/ubi-base-stack to paketobuildpacks/ubi8-base-stack across the Paketo projects (Docker containers references)

The rename from ubi to ubi8 is to better reflect that the stack is for ubi8. Just like ubuntu there are different streams of ubi (8, 9, ...) and this is
a good time to make the change.

## Rationale and Alternatives

The stack is ready to be promoted to paketo-buildpacks there is no obvious reasons not to move to packeto-buildpacks.

Alternative - leave the stack where is in paketo-community and define some additional milestones to be achived before it can be moved.

## Implementation

* Rename https://github.com/paketo-community/ubi-base-stack/ to https://github.com/paketo-community/ubi8-base-stack/
* Rename all references to paketo-community/ubi-base-stack to paketo-community/ubi8-base-stack across the Paketo projects (go project references and buildpack references)
* Rename all references to paketocommunity/ubi-base-stack to paketobuildpacks/ubi8-base-stack across the Paketo projects (Docker containers references)

This will take PRs to the two ubi builder repositories, but the main risk is missing updates during the transition. This is manageable and should not
have a major impact. 

## Prior Art


## Unresolved Questions and Bikeshedding

