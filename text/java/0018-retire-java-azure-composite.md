# Retire Java Azure Composite Buildpack

## Summary

This RFC is to retire and archive the Java Azure Composite buildpack.

## Motivation

1. The buildpack is not being maintained. It hasn't been updated in a long time.
2. No one has complained that it's not been updated, which is a signal no one is using it.
3. The buildpack is not ultimately necessary as the main feature is that it uses a different JVM, which one can do without creating an entirely new buildpack.
4. We are introducing the jvm-vendors buildpack, which will even more easily allow users to pick different JVMs.
5. We don't want to set an expectation that we will create composite buildpacks for every JVM vendor.

## Detailed Explanation

The process is simple.

1. Write a blog post announcing the change. Provide instructions for how to continue using Microsoft JDK without this buildpack.
2. Give users 30 days to update.
3. Archive the buildpack on Github. This will stop all workflows.

## Rationale and Alternatives

1. We don't want to have unmaintained buildpacks. This presents a bad look, but it can also result in users running old and insecure software.
2. Lack of effort/interest in maintaining this buildpack.

The only alternative is for someone to step forward and consistently maintain and update this buildpack. Even then, this buildpack doesn't fit with the future direction of where we want to go with the Java buildpacks so that probably wouldn't be sufficient.

## Implementation

See Detailed Explanation.

## Prior Art

N/A

## Unresolved Questions and Bikeshedding

None