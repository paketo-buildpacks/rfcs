# Extend .NET SDK Dependency

## Proposal

Replace the current .NET SDK dependency with the one that can be downloaded
from Microsoft which includes the runtimes that the SDK is dependent on to run.

## Motivation
As of .NET SDK version ~6.0.100, publish no longer properly functions for
certain types of .NET apps. See
https://github.com/paketo-buildpacks/dotnet-core/issues/670. Upon testing, we
were able to get the buildpack to function again if we used a .NET SDK
dependency that still had the runtime's libraries packaged with it. After
further investigation, we discovered that the removal of those local runtimes
caused the failure, leading us to believe that the .NET SDK no longer follows
the runtime search path that it used to.

It is becoming ever more apparent to me that Microsoft is dead set on not
having flexibility of file location during `dotnet publish`. Therefore I think
that we should capitulate to Microsoft and create an expected .NET Hive
installation. The .NET Hive is the expected structure and contents of the
official .NET SDK release provided by Microsoft. It includes the .NET SDK, .NET
Runtime, and ASP.NET. We can accomplish this installation structure by using
the .NET SDK dependency unaltered from Microsoft. As it stands currently, we
remove the .NET runtime and ASP.NET files included in the SDK distribution in
an effort to not have duplicated files. Installing the SDK as it is distributed
by Microsoft will make the buildpack less brittle to change in the future and
will construct a build environment that is more similar to what .NET developers
actually have installed on their machines and what Microsoft has in their
Docker images.

There are some additional advantages to using the .NET SDK dependency with its
included runtimes. Chief among them is that newer versions of the .NET SDK can
compile any version of an app for any given version of a runtime that is in the
same `major.minor` family. This means that we only have to support one version
of the .NET SDK for every `major.minor` version. Today, we support two patch
versions of each SDK `major.minor`. On top of that, we no longer need to align
our launch time runtime versions one-to-one with a single .NET SDK, which
simplifies our build-time version resolution logic. Also, because we only need
to support one .NET SDK, users that are building offline capable buildpacks can
build significantly smaller offline buildpacks.  Below are tables of each of
the sizes of each dependency and the size of the overall offline bundle right
now versus the proposed state.

### Current Situation
| Version | Size  |
|---------|-------|
| 3.1.417 | 53MB  |
| 3.1.418 | 53MB  |
| 6.0.201 | 88MB  |
| 6.0.202 | 89MB  |
| Total   | 283MB |

### .NET SDK + Runtimes XZ Compressed
| Version | Size  |
|---------|-------|
| 3.1.418 | 78MB  |
| 6.0.202 | 114MB |
| Total   | 192MB |


As you can see, the overall size of the offline buildpack has decreased by
~90MB (~30%). However, the overall size of each dependency has increased around
~30-50%. Based on data from
[Speedtest](https://www.speedtest.net/global-index), the world average download
speed at the time of writing is 62.52 Mbps. Therefore, the proposed increase in
artifact size would make downloads ~2.5 seconds slower for the world's average
user.  Subsequent builds would use the cached resource, as normal in the
buildpack.

## Implementation

The .NET SDK dependency referenced in the buildpack should be identical to the
one provided by Microsoft. This will allow us to install a fully realized .NET
SDK into a build-only layer; none of the extra SDK libraries or the additional
runtimes will be present at app runtime. The .NET Runtime and ASP.NET
buildpacks will still construct a runtime .NET Hive for themselves.

This change means that the .NET Publish buildpack will no longer need to
require the `dotnet-runtime` and `dotnet-aspnetcore` during build, as both of
those dependencies will now be included in the .NET SDK artifact. As a result,
the Paketo .NET Core Runtime and .NET Core ASP.NET buildpacks will no longer
need to set environment variables pointing to their dependencies' locations
during build.

## Alternatives
There are two alternatives that have been discussed among the .NET Maintainers
that remain unverified, however they are worth mentioning here for the sake of
completeness.

### Combine the Dependencies into One Buildpack
Keep the .NET SDK the same but make the same buildpack install both of the
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

#### Cons
- Lots of unnecessary file operations.
- Feels like the most opaque option.

## Unresolved Use Cases
During the course of the authoring this RFC a use case was brought to our
attention where users can have a project that requires 2 different .NET Runtime
versions at build time to compile correctly, an example of this type of app can 
be seen [here](https://github.com/macsux/multi-version-dotnet-project). 
The current version of the .NET Core buildpack does not support this use case, 
since only one version of the .NET Runtime is installed during a given build. 
This proposed change to the.NET SDK buildpack **does not** fully support this 
use case. Multi-runtime apps may work for online builds, since the .NET SDK can 
download needed compile-timedependencies. However, offline builds will fail 
because the SDK cannot download the missing .NET Runtime dependencies. This 
is considered out of scope for this RFC, but could be supported in the future.

## Source Material

- [SDK Version Policy](https://docs.microsoft.com/en-us/dotnet/core/versions/selection#the-sdk-uses-the-latest-installed-version)
- [Blog Post on SDK Behavior](https://weblog.west-wind.com/posts/2021/Jun/15/Running-NET-Core-Apps-on-a-Framework-other-than-Compiled-Version)
- [Speedtest Data](https://www.speedtest.net/global-index)
