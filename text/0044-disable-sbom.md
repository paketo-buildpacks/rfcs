# Provide Global Mechanism to Disable SBOM Generation

## Summary

Users should have a mechanism to disable the generation of SBOM documents
during the build process.

## Motivation

The generation of the SBOM documents for an image can be very time-intensive in
some cases. We have seen a doubling of build times for Node.js applications.
Additionally, some users are not interested in taking advantage of the SBOM
features of the buildpacks.

## Detailed Explanation

If a user wishes to produce an image that does not contain SBOM documents, they
can set the `BP_DISABLE_SBOM` environment variable to `true`. When unset, the
value of this environment variable is assumed to be `false`.

When `BP_DISABLE_SBOM` is set to `true`, buildpacks that allow SBOM to be
omitted from their output should refrain from generating or attaching an SBOM
in their outputs. This would apply to both new (Syft, CycloneDX, and SPDX
formats) and old (label) SBOM outputs.

Additionally, when this variable is set to `true` a buildpack should set an
image label of `io.paketo.sbom.disabled` to `true`. This label interface would
allow downstream consumers of the image to understand that SBOM generation had
been explicitly disabled.

## Rationale and Alternatives

Alternatively, we could not provide a mechanism to disable SBOM generation.
This does not seem like a great option as the build-time penalty introduced by
SBOM generation can be substantial.

We could also not specify anything at the organizational level and let each
buildpack subteam decide how they would like to handle this for their
ecosystem. However, with regards to this particular feature, it doesn't seem
like there would be a big need to have differing implementations of this flag
for each ecosystem. It would mean in some polyglot build scenarios that users
might need to specify that they'd like to disable SBOM generation in more than
one way. We and users would likely benefit more from a standardized feature
flag that worked uniformly across all buildpacks.

## Implementation

Any buildpacks wishing to implement this feature will be required to honor the
`BP_DISABLE_SBOM` environment variable. When set to `true` these buildpacks
will neither generate their SBOM documents, nor attach them to any of their
outputs.

Additionally, when the variable is set, these buildpacks will include the image
label `io.paketo.sbom.disabled` with a value of `true`.

## Other Notes and Details

In the Buildpacks Spec v0.7/ Platform Spec v0.8, the restorer phase of the
lifecycle [restores SBOMs from previous
builds](https://github.com/buildpacks/spec/blob/buildpack/v0.7/platform.md#outputs-2).
If a layer with an SBOM is restored by the lifecycle and the buildpack chooses
to reuse that layer, it does not need to explicitly remove that restored SBOM
from the layer.
