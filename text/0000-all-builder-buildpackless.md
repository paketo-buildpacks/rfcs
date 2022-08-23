# Make All Builders Buildpackless

## Summary

Builders that conglomerate buildpacks are unsustainable in the long run as
there is a layer cap set in place by Docker of 127 layers. We should stop
adding buildpack to our builder and instead only offer builders that contain
the stack and lifecycle. 

## Motivation

With the current size of the `full` builder we are already seeing users running
into issues with exceeding the layer limit of the buildpack when trying to add
custom buildpacks to their builds. This will only be exacerbated going forward
with the addition of new buildpacks into the Paketo project. Not only that the
`full` builders are completely unsustainable in the near future with proposals
such as the addition of APMs and the restructuring of existing buildpacks which
will both increase the layer count further.

Currently the purpose of the builders that include buildpacks is to allow first
time users to quickly plug in a large number of applications into the build
process and see what comes out. However using these loaded builders is not the
optimal solution if you are running builds for production images and the
builder images are large and bloated for most users who only have applications
in a couple of language domains.

This layer cap will only continue to become more of a problem and there is no
clear workaround so unfortunately a drastic restructuring is required.

## Rationale and Alternatives

### Language Specific Builders
Have one builder per language family that only supports that language family.

#### Pro
This guarantees that the builder will remain small as they will be confined to
a much smaller domain.

#### Cons
There is not much difference not much between this workflow and specifying the
buildpack that you want during build with a builder that contains no
buildpacks.

## Implementation

Announce this RFC in as many channels where there are potentially interested
parties and try to collect as much feedback as possible.

Announce a TBD deprecation window of the buildpack-full builders to allow for
the following actions:
- Maintainers spin up language specific builders if the maintainers of the
  language family buildpack find it necessary.
- Give integrators time to switch over.
- Examine our documentation and make any changes that would be required.
- Write up a builder to buildpack compatibility.

Then the following steps should be made for the transition:
- The buildpackless builder repos should be archived.
- The buildpack-full builders should have all buildpacks removed and a major
  version cut released.

## Prior Art

- Our currently existing buildpackless builders are our prescribed work around
  when hitting the layer limit.

## Unresolved Questions and Bikeshedding

- How would `pack` suggest a Paketo builder?
- Will this unduly affect users of the Paketo builders that are using systems
  that integrate with `pack` and `kpack`?
- Is there anything that can be done in the upstream?
- How long should the deprecation window period be?
- Who needs to be informed?

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
