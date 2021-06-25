# Switch `latest` to Base Builder

## Summary

`docker pull paketobuildpacks/builder` should pull the Base Builder.

## Motivation

The Base stack is the best choice for most applications. As such, the `latest` tag for stacks (`paketobuildpacks/build` and `paketobuildpacks/run`) already corresponds to the base stack.

Changing the `latest` tag on the Builder to Base would bring it into sync with the stacks.

## Detailed Explanation

Currently, `paketobuildpacks/builder:latest` points to the latest Full builder. This should change to point to the latest Base builder.

## Rationale and Alternatives

We could switch the `latest` tag in the stacks to point to Full to match the Builders.

This was rejected because we think the Base stack is the best option for most applications.
