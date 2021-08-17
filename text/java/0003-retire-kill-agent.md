# Retire Java Kill Agent

## Summary

This RFC is to retire and remove the Java Kill Agent from Paketo Java buildpack.

The Java Kill Agent is a JVM agent that is installed by the Paketo Java buildpack into generated container images. The agent is configured to run for all Java apps.

It has the following purpose:

1. **Primary Purpose**: when there is an OOME, cause the process to exit
2. Can optionally write a heap dump to a defined location prior to exit
3. Can optionally write a heap histogram to STDOUT prior to exit
4. Can optionally write memory usage stats to STDOUT prior to exit

It has some additional minor features:

1. Has a configurable limit & threshold for the number of OOMEs before it triggers
2. It supports `strftime` formatting of the defined path, so you can include date/time in the path
3. Histograms can be truncated, defaults to top 100 items

## Motivation

The JVM Kill Agent has some limitations and during the course of its lifetime, the JVM has gained new functionality which implements the majority of the Kill Agent's behavior. The proposal is to reduce complexity and use functionality built into the JVM instead of the JVM Kill Agent.

## Detailed Explanation

The JVM Kill Agent has some limitations/problems:

1. It will not currently work on the Paketo Tiny stack. The Kill Agent is a Rust application and at present is compiled to require a library that is not present in Tiny, nor is there desire to add the library to Tiny.
2. At present, all Java apps are run as "direct" process type. This means there is no shell and that the process will always run as PID1. In this scenario, the JVM Kill Agent cannot kill the application because it uses `SIGKILL` to terminate the process and this is not permitted for PID1. This means the primary purpose of the agent is not functional for virtually every Java application deployed through the Paketo Java buildpack.
3. Writing memory usage stats will fail if the heap is totally full or if the heap is too small. The agent cannot detect this and it will cause the app to not be killed, which is the primary purpose of the Kill Agent.
4. Writing memory usage stats will fail if the OOME is triggered by thread exhaustion. The agent will skip stats when this occurs.

As mentioned previously, the JVM now has similar functionality that's built-in.

1. `-XX:+ExitOnOutOfMemoryError` reproduces the primary behavior of the kill agent. It results in the JVM being stopped on exit.
2. `-XX:+HeapDumpOnOutOfMemoryError` and `-XX:HeapDumpPath=<some-path>` allow you to generate a heap dump & control where it’s written.
3. Java Native Memory Tracing can be used to generate memory statistics and have them dumped on exit.

This reproduces three out of the four purposes for the agent, including the primary purpose. It should also work more reliably, not having limitations three and four above, and not require additional libraries like the JVM kill agent.

The three parts that are missing with the native option:

1. There is no native way to write a heap histogram on exit.
2. The JVM does not provide threshold/limits, it will exit on the first OOME only.
3. It does not support `strftime` formatting in path names.

## Rationale and Alternatives

The rationale is to:

1. Reduce complexity by removing the agent. The agent is specific to buildpacks and so it adds complexity for new users.
2. Reduce development time by removing additional code that needs to be maintained.
3. Support the Tiny stack.

The alternative would be to invest development time to address the two primary issues with the agent. This would require finding an alternative, reliable way to terminate the JVM since `SIGKILL` won't work when running as PID1. It would also require investigating how to recompile the code such that it does not require the additional library (I believe this would mean static linking against musl libc instead of glibc, but that's not 100% clear). This would also likely require some updates and modernization of the code base which is getting old.

It may also be possible to take a hybrid approach and pull out functionality from the JVM Kill Agent that is present in the JVM. This would result in very little left in the kill agent, so it's unclear if the effort to do this would be worthwhile.

## Implementation

The following changes are proposed and necessary for parity with the current implementation.

1. Through [libjvm](https://github.com/paketo-buildpacks/libjvm/blob/ab0dbb0b2c8c9a537ebbf87c37e4d242c9fd1376/jvmkill.go#L35), the Java v3 CNB buildpacks will insert the `-XX:+ExitOnOutOfMemoryError`, `-XX:+HeapDumpOnOutOfMemoryError` and `-XX:HeapDumpPath=<some-path>` JVM arguments so they are picked up by any JVMs. This will ensure that the JVM is properly killed when an OOME event occurs.

    The heap dump will be optional and configured based on the presence of an environment variable `BPL_HEAP_DUMP_PATH` which provides the location of where to write the heap dumps (presumably that location would be on a mounted volume).

2. Stop using the Kill Agent immediately. This will require the removal of the agent from `libjvm` as well as any other buildpacks (GraalVM) directly adding it.

3. We will create a new buildpack that will function similar to the debug and jmx buildpacks but will be used to enable Java NMT. We will default enable Java NMT so that it can provide additional memory metrics. This will work by setting `-XX:NativeMemoryTracking=summary` and `-XX:+PrintNMTStatistics` which instructs the JVM to enable NMT and dump NMT statistics when the process exits.

    We will make it possible to disable Java NMT because there is a small amount of overhead for using Java NMT (Java NMT will display the overhead so users can determine if they feel it’s worth it). This will be done by setting `BPL_JAVA_NMT_ENABLED` to `false`.

The following changes are also being recommended. These add additional functionality that goes beyond what is present in the current implementation.

1. We will create a new buildpack that will function similar to debug and jmx but will be used to enable Java Flight Recorder. Flight Recorder will be opt-in based on the presence of an environment variable `BPL_JAVA_FLIGHT_RECORDER_ENABLED`, which defaults to `false`. In addition, there is an optional environment variable `BPL_JAVA_FLIGHT_RECORDER_PATH` that can be used to indicate the path at which JFR files are to be written. If set, the buildpack will configure a flight recording to be written to this location.

    JFR can also work via JMX, so the two buildpacks will be able to work together. If JMX is also enabled, one could connect remotely with Java Mission Control to directly interact with the JVM and manage JFR on-demand. This would be an alternative to using `BPL_JAVA_FLIGHT_RECORDER_PATH`.

2. We will create a new buildpack that will function similar to debug and jmx but will be used to install and enable the [Java Memory Assistant](https://github.com/SAP/java-memory-assistant). This is an advanced agent that can be used for flexible configuration of triggers to create heap dumps.

    The buildpack will optionally install the Agent it based on the `BP_JAVA_MEMORY_ASSISTANT_ENABLED` environment variable, which defaults to `false` (or disabled). There will be two more environment variables, `BPL_JAVA_MEMORY_ASSISTANT_ENABLED` which can be used to turn the agent on/off without rebuilding the application, and the `BPL_JAVA_MEMORY_ASSISTANT_PATH` environment variable which will provide the path at which the agent will write heap dumps (presumably a path on a mounted volume).

3. We will create a new buildpack that will install the [`jattach` binary](https://github.com/apangin/jattach). The `jattach` binary is a community tool that essentially replaces `jmap` + `jstack` + `jcmd` + `jinfo` which are not present in the OpenJDK JRE. This will be an opt-in buildpack that can be enabled for situations where a user needs this additional tool to debug application issues. The buildpack will simply provide the tool and ensure it’s on the PATH for easy use.

    This buildpack will be helpful to use in conjunction with Java NMT, as it can allow you to generate memory snapshots on-demand. It can also be helpful to use in conjunction with Java Flight Recorder as it can control flight recorder behavior also.

## Prior Art

N/A

## Unresolved Questions and Bikeshedding

1. There are many different JVM implementations now. Java Flight Recorder is a newer feature so it's unclear if this will function on all JVM implementations. Some initial tests show that it works on all of our JVM providers except Eclipse OpenJ9 (which is IBM-based, not Oracle based). The Java Flight Recorder buildpack will not attempt to differentiate between JVMs, if you ask it to enable JFR, it will add the flags regardless of the JVM vendor. We may need to revisit this if it turns out that there are more compatibility issues.

    - This will be addressed but by a future RFC. The idea that has been proposed is to fold JVM feature flag buildpacks like JMX, Debug and JRF into libjvm and the actual JVM vendor buildpacks. This will allow individual JVM vendor buildpacks to disable functionality that does not make sense or work for a particular vendor.
