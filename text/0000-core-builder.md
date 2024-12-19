# Ubuntu Core Builder

## Summary

Over the past, the Paketo project has created four different stacks and builders based on the Ubuntu Linux distribution. The difference is in the number of packages included which in turn is based on the requirements of the different buildpacks included.
This RFC proposes to create a new stack repository that will create a single `build` image and a number of `run` images based on the Ubuntu distribution and replace the existing `static`, `tiny` and `base` stacks. The `full` stack will be deprecated immediately, making the Jammy stack the last iteration of it.
This RFC further proposes to create a new builder repository that will create a single builder using the build image as a base layer and the `base` run image as the default `run` image.

Users will be able to use the new builder to build and run their applications using any of the language family buildpacks included. Instead of requireing a decision for an optimised builder, they can "just" start and later decide on an optimised `run` image.

## Motivation

The Paketo project will be easier to use for users - they can start without being asked to decide on optimisation.
The stacks and builders maintainer team will have less work to do - they will only need to maintain a single stack and builder instead of three.

## Detailed Explanation

We would replace the current `base`, `tiny` and `static` stacks with a single stack that includes all packages required by the buildpacks. Similarly, we would replace the current `base`, `tiny` and `static` builders with a single builder.

The `full` stack will be deprecated, making the present Jammy stack the last iteration of the `full` stack released by the Paketo team. This provides support for the full stack through [April of 2027](https://ubuntu.com/about/release-cycle), which is a sufficiently long deprecation period. Upon approval of this RFC, the Paketo Steering Committee will write a blog post announcing the stack changes and the deprecation of the full stack. The PHP buildpack will then need to be altered so that it can run on the new base stack or it will need to be changed to utilize extensions to install any additional packages that it requires over and above what is in the base image.

Container images have a layer limit and in the past, we have had issues with builders that include a lot of buildpacks because this can quickly cause the builder to hit the layer limit. To prevent this from happening, we will by default squash layers for all composite buildpacks included in the builder. This will be done by using the `--flatten` of `pack builder create`, and it should allow the builder to scale to include all of the Paketo buildpacks.

## Rationale and Alternatives

We could leave everything as it is. We would stick to maintaining four stacks repositories and eight builder repositories and creating new ones for every LTS we adopt. But that would increase the burden on the maintainers.

## Implementation

I would propose to create the new stack and builder as part of moving to Ubuntu Noble Numbat. I.e. 
- we should create a repository `paketo-buildpacks/ubuntu-noble-base-images`
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

This has been done in https://github.com/paketo-community/ubi-base-stack already. The `stacks` folder and `images.json` should give guidance on how to create multiple run images. Also, this is currently WiP in https://github.com/paketo-buildpacks/noble-base-stack/pull/11.

## Unresolved Questions and Bikeshedding
Q: With pack, it is very easy to specify a different run image. Is it similarly easy when not using pack?
A: We know this to work with some platforms. The notable exception is kpack.

For example:
Q: How does this impact the [language-specific builders RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0055-create-language-family-builders.md)?
A: It does not impact language-specific builders and Paketo buildpacks language families can continue to ship language-specific builders as needed.
Q: Does this proposal require Paketo buildpacks language families to implement an extension to switch or auto-select runtimes?
A: No. That is out of the scope of this RFC, and will be the topic of a future discussion and possibly future RFC.
- Spring: https://docs.spring.io/spring-boot/maven-plugin/build-image.html#build-image.customization
- Tekton: https://github.com/buildpacks/tekton-integration/tree/main/task/buildpacks/0.4#parameters
Q: What about the `full` stack and builders?
A: This proposal does not include the `full` builder and recommends that it be deprecated. If approved, this RFC will make the Jammy Full stack the last supported iteration of the full stack. There is presently only one buildpack, PHP, which requires the full stack and is thus impacted. This buildpack will be able to continue using the Jammy Full stack through [April 2027](https://ubuntu.com/about/release-cycle) with the goal of converting it to run on the new Noble all-in-one stack before that point.
