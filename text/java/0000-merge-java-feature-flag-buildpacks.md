# Merge Java Feature-Flag Buildpacks

## Summary

Presently, there are buildpacks part of the Java experience which do not provide additional dependencies, but only add additional JVM specific flags to trigger behavior. This RFC refers to these buildpacks as "feature-flag" buildpacks.

The following feature-flag buildpacks exist presently:

- [Debug](https://github.com/paketo-buildpacks/debug)
- [JMX](https://github.com/paketo-buildpacks/jmx)

There are plans to add two additional buildpacks:

- Java NMT
- Java Flight Recorder

## Motivation

There are a few motivations for this change:

1. Consistency. At present, some JVM options are configured through libjvm and some are configured through external buildpacks. We can enable libjvm to support all of these use cases and have a more consistent experience. If a feature is facilitated through the JVM, then it's configured via libjvm.
2. Reduce maintenance. There is additional overhead in maintaining each buildpack. We have two feature-flag buildpacks now, but will have two more coming. If we move feature-flag compatibility into libjvm then we reduce the number of buildpacks by four.
3. Most feature-flags are supported by all JVMs, but when you get into Java NMT and Java Flight Recorder, that's not true. Moving functionality into libjvm, allows us to enable a JVM Vendor buildpack to opt-out of features that it does not support.

## Detailed Explanation

We are proposing the following:

1. Archive Debug & JMX buildpacks. Remove them from the Java and Java Azure composite buildpacks.
2. Do not create Java NMT or Java Flight Recorder buildpacks.
3. Implement Debug, JMX, Java NMT and Java Flight Recorder functionality through libjvm.
4. Implement an interface in libjvm that is flexible so JVM provider buildpacks can opt-out of any feature their particular JVM does not support. The default will be to support all options.

## Rationale and Alternatives

Alternatives:

- We could achieve consistency by moving all JVM feature-flag options into buildpacks, but this would create more buildpacks and have more maintenance burden. It would also require feature flag buildpacks to have knowledge specific to individual JVM variants, so they know which variants support which flags.

## Implementation

The highlights are above in the [Details](#detailed-explanation) section.

In regards to libjvm, libjvm has a primitive called a helper. The plan is to replace the feature-flag buildpacks with feature-flag helpers. A helper for Debug, JMX, Java NMT, and Java Flight Recorder. The helper executes at runtime, so this enables turning on/off these features at runtime.

## Prior Art

There is existing functionality implemented through libjvm.

- Setting `-XX:ActiveProcessorCount`
- Enabling `java.security` customizations
- Certificate loading
- Adding security providers

## Unresolved Questions and Bikeshedding

N/A
