# Process for Adding a New Builder/Base Images

## Summary

This RFC documents the end-to-end process for adding a new builder and base
images to the Paketo Buildpacks project. It also covers when a separate RFC
is required for upcoming builders and base images that share the same
characteristics as existing ones.

## Motivation

Adding a new builder and base images spans across many repositories. Without a shared guide,
contributors reinvent steps and miss follow-ups such as samples, the website, or
the pack CLI. This RFC is a general guideline—not a rigid checklist—so teams can
move faster and still cover the full path from proposal to announcement.

For new builders and base images that follow the same pattern as existing ones
(for example, a new Ubuntu LTS release or a new UBI major version that reuses the
current repository layout, CI, and builder structure), this RFC is sufficient.
A separate RFC is not required unless the Steering Committee asks for one.

## Detailed Explanation

The process for adding a new builder and base images consists of the following phases. Each phase depends on the previous one.

### 1. Notify Steering Committee

Notify the Steering Committee (SC) through Slack that you intend to add new base
images/builders and propose the name of the repositories for the base images/builders.

If the proposal follows the same pattern as existing builders and base images
and there is no disagreement from the SC, the separate RFC process can be omitted.
The SC may still request RFCs, or any SC member may object and ask for RFCs.

If RFCs are required (or if the proposal differs from existing builders and
base images implementations), open an RFC for the base images and an RFC for the
builders before continuing.

### 2. Create the Base Images

Once the SC has agreed (or any required base images RFC has been accepted):

- Confirm the base images repository exists (created in phase 1)
- Submit an initial implementation PR to the repository
  - Example: https://github.com/paketo-buildpacks/ubi-9-base-images/pull/1
  - Example: https://github.com/paketo-buildpacks/ubuntu-resolute-base-images/pull/2
- Make a release

### 3. Create the Builders

Once the SC has agreed (or any required builders RFC has been accepted):

- Confirm the builder repository exists (created in phase 1)
- Commit an initial implementation that includes the buildpackless builder and the full builder. The full builder should have no buildpacks yet.
  - Example commit: https://github.com/paketo-buildpacks/ubuntu-resolute-builder/commit/ee51d3dc53c69008bf81417799c177fcdb3ae71f
  - Example PR: https://github.com/paketo-buildpacks/ubi-9-builder/pull/1
- Make a release

### 4. Validate Composite Buildpacks

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

#### Other Language Ecosystems

- _(To be documented by the respective subteams)_

### 5. Add the Builder to Samples

- Submit a PR to the samples repository for adding the new builder.
  - Example: https://github.com/paketo-buildpacks/samples/pull/1165
  - Example: https://github.com/paketo-buildpacks/samples/pull/1535

### 6. Update the Full Builder

Once a language buildpack (for example Node.js) has been fully tested against the new buildpackless builder, add it to the full builder.

- Smoke tests should use samples from the samples repository and stay synchronized via the `builders.json` file

### 7. Add the Builder to the Paketo Website

Update the Paketo website to list the new builder on the Builders page.

- Submit a PR to the website repository
  - Example: https://github.com/paketo-buildpacks/paketo-website/pull/907
  - Example: https://github.com/paketo-buildpacks/paketo-website/pull/1032

### 8. Announce the Builder

Write and publish a blog post announcing the new builder so users and language teams can start adopting it.

- Publish on the [Paketo blog](https://blog.paketo.io/)

### 9. Add the Builder to the Pack CLI

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
- When is a language family buildpack considered tested against the builder?
- Should we first announce the builder and then add it to pack CLI or the opposite?
- Should we wait for all the language family buildpacks to adopt it before we announce it or register it in the pack CLI?
