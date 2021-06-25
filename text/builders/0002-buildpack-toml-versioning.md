# Checking In and Versioning Builder.toml Files

## Proposal

We should check in a `builder.toml` file for each version of the available
builders. When the version of the builder gets released, we should publish a
release and tag the repo with the correct version. There exists three different
builders that are released separately, `full`, `base`, and `tiny`. Each builder
should have its own repository.

## Motivation

Paketo users frequently ask to be able to see the `builder.toml` files used to
create any of the Paketo Builders so that they could create custom builders
easily. Right now builders are created in a concourse task that creates a
temporary `builder.toml` and uses it in pack create-builder. The `builder.toml`
file isn't saved anywhere and is lost after the task ends.

We should always strive for strict versioning and reproducibility, and right
now we have neither. It's very difficult to tell what version of what buildpack
are in each builder, and this will make that very clear. All you would have to
do is look at the repo at the right tag. Also, if you wanted to rebuild the
builder, you could simply check the repo out the the correct tag.

## Implementation (Optional)

The proposed solution for updating the `builder.toml` is the following:
* On some chron schedule, run a Github Action to grab the latest tag of each
  buildpack that is a part of the builder
  * Also grab the latest version of the lifecycle and builder image.
* Create a temporary `builder.toml` file with those versions.
* Check if there is a diff between the new temporary `builder.toml` and the one
  that is already checked into the repo.
  * If there is no diff do nothing.
  * If there is a diff,  submit a PR with the new `builder.toml` to update it.
* On each PR, run the smoke-tests.
* Automatically merge the PR on passing tests.

In order to publish:
* Cut a release with a new version whenever the maintainer wants.
  * Because the current line of builder are at `0.0.x`, we should start with
    `0.1.0`.
* Initally push a a temp gcr path (gcr.io/paketo-buildpacks/builder-tmp:full).
* Start publish to all our official paths when ready.

The chron schedule is the best way to keep the `builder.toml` up to date in a
community friendly way because it is transparent and requires no work of the
buildpack maintainers.

## Alternative Implementations

1. Use a Concourse pipeline to check for new buildpack versions and send
   dispatches to the builder repos to create PRs.

   This is less than ideal because it forces other users to have to update the
   Concourse pipelines when they have new buildpacks. Using different systems
   such as Concourse and Github Actions across different repos also adds
   technical debt.

2. Use Github Actions to send a dispatch to the builder from each buildpack
   that feeds into the builder to notify it to create PRs.

   This is less than ideal because every repo that feeds into a builder would
   need to implement a Github Actions workflow that would be able to send a
   dispatch to the builder repos. We do not want to put that burden onto the
   maintainers of buildpacks.

## Source Material (Optional)

https://github.com/paketo-buildpacks/builder/issues/27
https://github.com/paketo-buildpacks/builder/issues/28
