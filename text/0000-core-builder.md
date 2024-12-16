# Ubuntu Core Builder

## Summary

Over the past, the Paketo project has created four different stacks and builders based on the Ubuntu Linux distribution. The difference is in the number of packages included which in turn is based on the requirements of the different buildpacks included.
This RFC proposes to create a new stack repository that will create a single `build` image and a number of `run` images based on the Ubuntu distribution and replace the existing `static`, `tiny` and `base` stacks.
This RFC further proposes to create a new builder repository that will create a single builder using the build image as a base layer and the `base` run image as the default `run` image.

Users will be able to use the new builder to build and run their applications using any of the language family buildpacks included. Instead of requireing a decision for an optimised builder, they can "just" start and later decide on an optimised `run` image.

## Motivation

The Paketo project will be easier to use for users - they can start without being asked to decide on optimisation.
The stacks and builders maintainer team will have less work to do - they will only need to maintain a single stack and builder instead of three.

## Detailed Explanation

We would replace the current `base`, `tiny` and `static` stacks with a single stack that includes all packages required by the buildpacks. Similarly, we would replace the current `base`, `tiny` and `static` builders with a single builder.

## Rationale and Alternatives

We could leave everything as it is. We would stick to maintaining four stacks repositories and eight builder repositories and creating new ones for every LTS we adopt. But that would increase the burden on the maintainers.

## Implementation

I would propose to create the new stack and builder as part of moving to Ubuntu Noble Numbat. I.e. 
- we should create a repository `paketo-buildpacks/stack-ubuntu-noble`
- we should take the `build` image content from the `paketo-buildpacks/noble-base-stack` repository and apply it to `paketo-buildpacks/stack-ubuntu-noble`
- we should take the `run` image content from the `paketo-buildpacks/noble-base-stack` repository and apply it to `paketo-buildpacks/stack-ubuntu-noble`
- we should take the `run` image content from the `paketo-buildpacks/noble-tiny-stack` repository and apply it to `paketo-buildpacks/stack-ubuntu-noble` as additional run image
- we should take the `run` image content from the `paketo-buildpacks/noble-static-stack` repository and apply it to `paketo-buildpacks/stack-ubuntu-noble` as additional run image
- we should create a repository `paketo-buildpacks/builder-ubuntu-noble` and another`paketo-buildpacks/builder-ubuntu-noble-buildpackless`
    - we should use the above `build` image as a base layer for the `builder` image
    - we should use the above `run` image as the default `run` image for the `builder.toml`
    - we should use the above `run-static` and `run-tiny` images as additional `run` images for the `builder.toml`

I would propose to delete the `paketo-buildpacks/noble-base-stack`, `paketo-buildpacks/noble-tiny-stack` and `paketo-buildpacks/noble-static-stack` repositories.
I would propose to delete the `paketo-buildpacks/builder-noble-buildpackless-static`, `paketo-buildpacks/builder-noble-buildpackless-tiny` and `paketo-buildpacks/builder-noble-buildpackless-base` repositories.

## Prior Art

None.

## Unresolved Questions and Bikeshedding

What about the `full` stack and builders?
