# Extend .Net SDK Dependency

## Proposal

Reconfigure the .Net SDK dependency to be identical to the one that can be downloaded from Microsoft which includes the runtimes that the SDK is dependent on to run.

## Motivation
As of [.Net SDK version ~6.0.100 publish no longer properly functions for
certain types of .Net
apps](https://github.com/paketo-buildpacks/dotnet-core/issues/670). Upon
testing we were able to get the buildpack to function again if we used an .Net
SDK dependency that still had the runtimes libraries packaged with it. After
further investigation we discovered that the removal of those local runtimes
was what was causing the failure, leading us to believe that the .Net SDK no
longer follows the runtime search path that it used to.

It is becoming ever more apparent to me that Microsoft is dead set on not
having flexibility of file location during `dotnet publish` therefore I think
that we should capitulate to Microsoft and create an expected .Net Hive
installation, which is a layer where the file structure matches the layout that
is present in the official .Net SDK release from Microsoft. I think that this
will make the buildpack less brittle to change in the future and will construct
a build environment that is more similar to what .Net developers actually have
installed on their machines and what Microsoft has in their Docker images.

There are some additional advantages to using the .Net SDK dependency with its
included runtimes chief among them being that newer versions of the .Net SDK
can compile any version of an app for any given version of a runtime that is in
the same `major.minor` family. This would mean that we would only have to
support one version of the .Net SDK for every `major.minor` version as opposed
to the two we currently support. On top of that we would no longer need to
align our launch time runtime versions one-to-one with a single .Net SDK
meaning that our version resolution logic would be vastly simplified. Also
because we would only need to support one .Net SDK, users that are building
offline capable buildpacks would be able to build a significantly smaller
offline buildpack.  Below are tables of each of the sizes of each dependency
and the size of the overall offline bundle right now versus the proposed state.

### Current Situation
| Version | Size  |
|---------|-------|
| 3.1.417 | 53MB  |
| 3.1.418 | 53MB  |
| 6.0.201 | 88MB  |
| 6.0.202 | 89MB  |
| Total   | 283MB |

### .Net SDK + Runtimes XZ Compressed
| Version | Size  |
|---------|-------|
| 3.1.418 | 78MB  |
| 6.0.202 | 114MB |
| Total   | 192MB |


As you can see the overall size of the offline buildpack has decreased by
~90MB, however the overall size of each dependency has increased around
~30-50%. Based on data from
[Speedtest](https://www.speedtest.net/global-index), with the world average at
the time of writing being 62.52 Mbps, the average increase in download times
would be around ~2.5 seconds for the new artifact, however subsequent builds
would obviously use the cached resource.

## Implementation

When constructing the .Net SDK dependency the pipeline should no longer strip
any files out of the given dependency. It should instead take all of the files
from the Microsoft release and compress them as we are doing for our current
.Net SDK dependency. This will allow us to install a fully realized .Net SDK
into a build only layer meaning that none of the extra SDK libraries or the
additional runtimes will be present during build. The runtime buildpacks will
still construct a runtime .Net root for themselves.

## Alternatives
There are two alternatives that have been discussed among the .Net Maintainers
that remain unverified, however they are worth mentioning here for the sake of
completeness.

### Combine the Dependencies into One Buildpack
Keep the .Net SDK the same but make the same buildpack install both of the
runtimes as well as the SDK. By doing this we could construct two different
layers directly, one for build and one for launch.

#### Cons
- This requires a large restructure that makes out buildpacks less modular.
- There will be a large amount of complexity and business logic in during build
  that will be unique the just that buildpack and not widely applicable.

### Construct an Ad Hoc Hive Directory at Build Time
We could pass information of the location of all of the dependencies to the
Dotnet Publish buildpack that it could use to construct a Hive directory for
itself.

####
- Lots of unnecessary file operations.
- Feels like the most opaque option.

## Source Material

- [SDK Version Policy](https://docs.microsoft.com/en-us/dotnet/core/versions/selection#the-sdk-uses-the-latest-installed-version)
- [Blog Post on SDK Vehavior](https://weblog.west-wind.com/posts/2021/Jun/15/Running-NET-Core-Apps-on-a-Framework-other-than-Compiled-Version)
- [Speedtest Data](https://www.speedtest.net/global-index)
