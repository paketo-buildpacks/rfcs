# Extract `jam` into Dedicated Repository

## Proposal

Currently, the source for the `jam` cli tool resides inside of the
`cargo` package which itself is inside of the `packit` repository. All `jam`
source code should be extracted from its current location and be relocated into
its own repository.

## Motivation

Initially `jam` was placed inside of the `packit` repository because it was the
dedicated packaging tool for buildpacks that are written in `packit`. However,
its functions have expanded beyond just packaging `packit` buildpacks and now
encompass a wide variety of functions such as:
* Summarizing the contents of a buildpackage
* Updating `builder.toml` files
* Updating metabuildpack `buildpack.toml` dependencies

All of these are generic functions that could work with any buildpack
regardless of whether or not it is written using `packit`.

By extracting the `jam` cli, a number of positives can be achieved:
* The version of `packit` and `jam` are no longer interlocked making the
  releases of both more SemVerically sound
* It will clean up the `packit` codebase of any code that is not api or helper
* It will make `jam` more discoverable and we could potentially expand `jam`
  into a much more useful and universal buildpacks development tool for authors
  in the buildpacks community

## Implementation

A new repository should be created that is owned by the tooling maintainers
named `jam`. Then all `jam` source code should be moved into this repository
from `packit`. Once that is complete and a release has been cut, all scripts
that currently download `jam` need to be updated in order to download `jam`
from it's new release home. A message should be added to the `packit` README
that the `jam` release has been moved to a new repository.

## Unresolved Questions and Bikeshedding

* How long should that redirect message remain present on the README for
  `packit`?

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
