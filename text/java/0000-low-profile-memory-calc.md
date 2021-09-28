# Memory Calculator Low Profile Mode

## Summary

Presently, the Memory Calculator used by the Paketo Java buildpacks, those that utilize `libjvm`, has a large, fixed minimum requirement for amount of RAM an application needs to start.

For most Java apps, the minimum requirement determined by the memory calculator is: `10M direct memory + 240M code cache + 250M thread stack + metaspace (variable but 80 - 120M is typical) + heap`. This equates to 500M of RAM before even counting the metaspace and heap which have application specific needs that can easily double this requirement. This in turn means that it's common to require at least 1G of RAM to run a Java container image created with the Java buildpacks.

These default values were selected for good reason. They provide a default memory configuration that is performant and scaled for a busy web application handling hundreds of request per second. Not all applications fit into this profile though.

There are other profiles of applications that can accept the performance trade-off of using less RAM and happily with the smaller memory footprint. For example, new users trying out demo apps, low-volume web applications (like internal business apps for small teams), proof-of-concept applications, or non-web applications can all often run with less RAM.

This has the following impact:

- Poor initial experience for users as they try to use less RAM and failures occur
- Does not compare well to running Java apps with Docker, where this is not enforced
- Gives the impression something related to buildpacks requires more RAM for Java apps
- Increased cost for PoC, low-volume and non-web apps
- Users of the Java buildpack on platforms where buildpack behavior is masked or hidden may see little beyond that the build failed, creating a difficult to debug situation

To be transparent, the present state of the memory calculator does not prohibit users from further reducing memory costs, however, it requires manual tuning of buildpack and JVM flags to do this. That is something which is acceptable on a small scale and for experienced users. New users would need to research the settings to adjust. Users with a large number of applications likely don't want to manually customize every one.

## Motivation

There are a few motivations for this change:

1. Facilitate a better new user experience
2. Decrease costs for applications that can trade performance for a reduced memory footprint
3. Reduce the number of cases that a user would need to customize JVM memory settings manually
4. Improved out-of-the-box experience for users one some alternative platforms

## Detailed Explanation

To handle this specific use case, we will create a "low-memory" profile. The low memory profile will be applied when the container memory limit is below the static threshold of 1G of container memory.

When the low-memory profile is enabled, the memory calculator will make the following adjustments to it's algorithm.

1. Lower the thread stack size (`-Xss`). This is the per thread amount of memory the JVM requires. It defaults to 1M and the JVM allows going down to as low as 256k. Most apps work fine with 256k, unless using a heavy amount of recursion.

2. Lower the expected number of threads. By default, the memory calculator will allocate memory for 250 threads. In some cases, buildpacks will adjust this lower automatically. An example is for Spring Boot Webflux apps, this is lowered to 50 by default.

3. Lower the code cache size. The JVM caches JIT'd code so it doesn't have to rebuild it. This is in memory. It defaults to 240M. You can lower this value, but it comes at the cost of reduced JVM performance.

The memory calculator will adjust the three values in proportion to the amount of memory available compared to the baseline threshold of 1G. For example, if you select 512M then it will reduce by 1/2. If you select 256M then it will reduce by 1/4.

The minimum value for thread stack size is 256K (Java 8, 11, & 17). The minimum code cache size is 2496K (Java 8, 11, and 17). There is no minimum thread count defined by the JVM, however, the JVM does need to create some threads to simply exist (exactly how many varies based on Java version and GC algorithm, among other factors). As such, the memory calculator will not reduce the thread count below 30 threads. You can force it to go below this limit at your own peril by setting the thread count with `$BPL_JVM_THREAD_COUNT`.

The minimum value for heap is 2M (Java requirement). This means that you can get into some situations where the memory calculator will do it's best to configure the JVM, but the only configuration it can create does not provide sufficient heap space for your application. At this point, a user would need to take control and manually reduce the thread stack size, thread count or code cache size such that there is sufficient memory remaining. It is strongly recommend that you do not set the heap size directly, i.e. `-Xmx` because the memory calculator will do this automatically to whatever free memory is available after all other JVM memory regions are taken into account. In addition if you set `-Xmx` too high you can make memory calculator fail and too low will leave unused memory in the container.

The minimum selection with this algorithm would be: `256k * 30 threads + 2.5M code cache + 10M direct = 20M` plus metaspace and heap. This compares to `500M` plus metaspace and heap for the current memory calculator implementation.

Here are some example calculations based on the rules above:

| thread stack | thread count | code cache | metaspace [1] | heap [2] | direct | container memory | Notes                                                                                |
| ------------ | ------------ | ---------- | ------------- | -------- | ------ | ---------------- | ------------------------------------------------------------------------------------ |
| 1M           | 250          | 240M       | 100M          | 424M     | 10M    | 1G               | Baseline                                                                             |
| 512K         | 125          | 120M       | 100M          | 220M     | 10M    | 512M             | Container memory reduced by 1/2 the baseline                                         |
| 256K         | 62           | 60M        | 100M          | 70M      | 10M    | 256M             | Container memory reduced by 1/4 the baseline                                         |
| 384K         | 250          | 240M       | 100M          | 580M     | 10M    | 1G               | Baseline, user has fixed thread stack at 384K                                        |
| 384K         | 125          | 120M       | 100M          | 235M     | 10M    | 512M             | Container memory reduced by 1/2 the baseline, user has fixed thread stack at 384K    |
| 384K         | 62           | 60M        | 100M          | 62M      | 10M    | 256M             | Container memory reduced by 1/4 the baseline, user has fixed thread stack at 384K    |
| 1M           | 50           | 240M       | 100M          | 624M     | 10M    | 1G               | Baseline, user has fixed thread count to 50                                          |
| 512K         | 50           | 120M       | 100M          | 257M     | 10M    | 1G               | Container memory reduced by 1/2 the baseline, user has fixed thread count to 50      |
| 256K         | 50           | 60M        | 100M          | 73M      | 10M    | 1G               | Container memory reduced by 1/4 the baseline, user has fixed thread count to 50      |
| 1M           | 250          | 120M       | 100M          | 544M     | 10M    | 1G               | Baseline, user has fixed code cache size to 120M                                     |
| 512K         | 125          | 120M       | 100M          | 219M     | 10M    | 1G               | Container memory reduced by 1/2 the baseline, user has fixed code cache size to 120M |
| 256K         | 62           | 120M       | 100M          | 10M      | 10M    | 1G               | Container memory reduced by 1/4 the baseline, user has fixed code cache size to 120M |

[1] - Metaspace will vary per application. For these calculations it is fixed at 100M.
[2] - Heap is dynamically adjusted to consume whatever memory is remaining while not exceeding the container memory limit.

## Rationale and Alternatives

Alternatives:

- Do nothing. Memory calculator will continue it's present course and users will need to manually customize JVM settings for lower memory scenarios.
- The algorithm outlined above for determining the memory settings is only one possibility. Other algorithms could be used instead. This one was selected because it's perceived to be intuitive, effective and at the same time easy to implement.
- Allow disabling the memory calculator. This would allow users to take full control, but dramatically increases the likelihood of obtuse and difficult to debug failure scenarios (i.e. self-inflicted foot wounds).

## Implementation

This will require updating the libpak memory calculator helper.

It will need to:

- Capture the current container memory limit
- Compare that to the threshold of 1G and calculate a scaling factor (i.e. `current / 1G = scaling factor`)
- Perform a standard calcualtion for 1G
- Adjust the thread stack size, thread count and code cache size, scaling them down by the scaling factor (i.e. `value - (value * scaling) = new value` ). Values should be in KB and fractional results all rounded down for safety. Do not adjust a value if a user has manually fixed this value.
- Warn if a user has set `-Xmx`, which can cause unexpected problems.
- Enforce minimum defined requirements. Fail immediately, if below a spec defined minimum.
- Test the scenarios outlined in the table above. Confirm expected results.
- Include intuitive error messages explaining the users next steps, if there is a memory calculator failure.
- Document the new behavior (and existing behavior, which isn't documented) as well as limitations/non-perfect nature of low profile mode).

## Prior Art

- None

## Unresolved Questions and Bikeshedding

- Is this the right algorithm? Can we do better?
