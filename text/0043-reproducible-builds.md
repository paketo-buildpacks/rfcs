# Expanding the Criteria for Reproducible Builds

## Summary

Given the same set of inputs and without leveraging caching, Paketo buildpacks
should reproducibly build images.

## Motivation

The current set of Paketo buildpacks do a reasonably good job of helping
developers to ship reproducible build artifacts. They reuse layers where
possible, and don't modify files in ways that aren't reproducible. So, for
users taking advantage of the caching behaviors of CNBs, the reproducible build
story is largely solved.

However, we can do better in some other cases. Specifically, given a codebase
that is not changing, a set of buildpacks that are not changing, and stacks
that are not changing, we should be able to reproduce the exact same image on
subsequent runs without leveraging the caching features of CNB.

Unfortunately, there are some cases where we've made choices that prevent this
type of reproducible build. These cases should be removed or minimized to the
greatest extent possible.

## Detailed Explanation

Many of the buildpacks contain behavior that results in non-reproducible images
due to how they treat layer metadata. Specifically, they include a `built_at`
metadata field that includes a timestamp for the instant that this layer was
built.

Including this type of field means that two subsequent runs of a build with
identical inputs will produce different images.

## Alternatives

Alternatively, we could assert that Paketo buildpacks will not be making an
effort to enable this type of reproducible build. However, this path doesn't
seem reasonable. Supporting these types of reproducible builds is obviously
possible given different choices that are not fundamental to the value
proposition of buildpacks.

## Implementation

We should remove the `built_at` fields from all buildpack layers that include
them. In our test suites that leverage this field to assert layer reuse, we
should instead prefer to compare layer SHA values across rebuilds.

We could also include new integration testing of this specific type of
reproducible build scenario.

## Unresolved Questions and Bikeshedding

* How do we handle versioning of buildpacks that remove this layer metadata
  field? Is this part of the public API?
