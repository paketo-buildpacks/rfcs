# Process for Adding a New Builder/Base images

## Summary

This RFC documents the end-to-end process for adding a new builder and base
images to the Paketo Buildpacks project.

## Motivation

Adding a new builder and base images spans accross many repositories. Without a shared guide,
contributors reinvent steps and miss follow-ups such as samples, the website, or
the pack CLI. This RFC is a general guideline—not a rigid checklist—so teams can
move faster and still cover the full path from RFCs to announcement.

## Detailed Explanation

The process for adding a new builder and base images consists of the following phases. Each phase depends on the previous one.

### 1. Open RFC for the Base Images (Stacks)

Propose the new base images by opening an RFC in the [rfcs](https://github.com/paketo-buildpacks/rfcs) repository.

Example RFCs:

- [RFC 0065 - Create UBI9 base images](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0065-add-ubi9-base-images.md)
- [RFC 0010 Propose adding Resolute Raccoon base images](https://github.com/paketo-buildpacks/rfcs/pull/332)

### 2. Open RFC for the Builders

Propose the new builders in a separate RFC.

Example RFCs:

- [RFC 0066 - Create UBI9 builders](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0066-add-ubi9-builders.md)
- [RFC 0009 Ubuntu Resolute builders](https://github.com/paketo-buildpacks/rfcs/pull/333)

### 3. Create the Base Images

Once the base images RFC has been accepted:

- Ask the Steering Committee to create the base images repository with the name mentioned in the RFC
- Submit an initial implementation PR to the repository
  - Example: https://github.com/paketo-buildpacks/ubi-9-base-images/pull/1
  - Example: https://github.com/paketo-buildpacks/ubuntu-resolute-base-images/pull/2
- Make a release

### 4. Create the Builders

Once the builders RFC has been accepted:

- Ask the Steering Committee to create the builder repository with the name mentioned in the RFC
- Commit an initial implementation that includes the buildpackless builder and the full builder. The full builder should have no buildpacks yet.
  - Example commit: https://github.com/paketo-buildpacks/ubuntu-resolute-builder/commit/ee51d3dc53c69008bf81417799c177fcdb3ae71f
  - Example PR: https://github.com/paketo-buildpacks/ubi-9-builder/pull/1
- Make a release

### 5. Validate Composite Buildpacks

Add the buildpackless builder to integration testing of each buildpack that should support the new Builder.

#### Node.js Buildpacks

Add the buildpackless builder to Node.js buildpack integration testing:

- ubi-nodejs-extension ([example](https://github.com/paketo-buildpacks/ubi-nodejs-extension/pull/375))
- node-start ([example](https://github.com/paketo-buildpacks/node-start/pull/738))
- npm-start ([example](https://github.com/paketo-buildpacks/npm-start/pull/713))
- npm-install ([example](https://github.com/paketo-buildpacks/npm-install/pull/969))
- yarn ([example](https://github.com/paketo-buildpacks/yarn/pull/836))
- node-engine (only for non-UBI builders)
- yarn-start ([example](https://github.com/paketo-buildpacks/yarn-start/pull/718))
- yarn-install ([example](https://github.com/paketo-buildpacks/yarn-install/pull/987))
- nodejs (composite buildpack) ([example](https://github.com/paketo-buildpacks/nodejs/pull/1170))

#### Java Buildpacks

- _(To be documented by the Java subteam)_

#### Other Language Ecosystems

- _(To be documented by the respective subteams)_

### 6. Add the Builder to Samples

- Submit a PR to the samples repository for adding the new builder.
  - Example: https://github.com/paketo-buildpacks/samples/pull/1165
  - Example: https://github.com/paketo-buildpacks/samples/pull/1535

### 7. Update the Full Builder

Once a language buildpack (for example Node.js) has been fully tested against the new buildpackless builder, add it to the full builder.

- Smoke tests should use samples from the samples repository and stay synchronized via the `builders.json` file

### 8. Add the Builder to the Paketo Website

Update the Paketo website to list the new builder on the Builders page.

- Submit a PR to the website repository
  - Example: https://github.com/paketo-buildpacks/paketo-website/pull/907
  - Example: https://github.com/paketo-buildpacks/paketo-website/pull/1032

### 9. Announce the Builder

Write and publish a blog post announcing the new builder so users and language teams can start adopting it.

- Publish on the [Paketo blog](https://blog.paketo.io/)

### 10. Add the Builder to the Pack CLI

After the announcement, and once language teams have adopted the new builder, register it as a trusted builder in the pack CLI.

- Example: https://github.com/buildpacks/pack/pull/2383

## Rationale and Alternatives

### Doing nothing

Leave the process undocumented. Contributors would keep rediscovering steps and
could miss samples, website updates, announcements, or pack CLI registration.

## Implementation

This RFC is itself the implementation.

## Prior Art

Recent builder and stack/base images RFCs

- [RFC 0065 - Create UBI9 base images](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0065-add-ubi9-base-images.md)
- [RFC 0066 - Create UBI9 builders](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0066-add-ubi9-builders.md)
- [Propose adding Resolute Raccoon base images](https://github.com/paketo-buildpacks/rfcs/pull/332)
- [Ubuntu Resolute builders](https://github.com/paketo-buildpacks/rfcs/pull/333)

## Unresolved Questions and Bikeshedding

- What is the testing suite against the new builder of each language family buildpack?
- When a family language buildpack is consider that has been tested against the builder?
- Should we first announce the builder and then add it to pack CLI or the opposite?
- Should we wait for all the language family buildpacks to adopt it, before we announce it or register it to the Pack CLI?
