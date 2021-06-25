# Publish Full Builder to `full-cf` Tag

## Summary

`docker pull paketobuildpacks/builder:full-cf` should pull the Full Builder.

## Motivation

The Full builder was created to replace the Full-CF builder. This would allow us to stop shipping the Full-CF builder.

## Detailed Explanation

Currently, `paketobuildpacks/builder:full-cf` points to the latest Full-CF builder. This should change to point to the latest Full builder.

## Rationale and Alternatives

We could send out a deprecation notice to formally deprecate the Full-CF builder and tag.

We would prefer not to do this yet as it will break users who have automation relying on the `full-cf` tag. It would also require us to continue shipping the Full-CF builder during the deprecation period, which we would prefer not to do.
