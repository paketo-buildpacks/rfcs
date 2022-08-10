# Reduce Build Complexity of .NET Runtimes

## Proposal

Today, the .NET Core language family buildpack contains two components that are
responsible for installing versions of the .NET runtime. They install
dependencies hosted by the Paketo dep-server. These buildpacks run their build
phases *before* application source code is compiled. This RFC proposes that the
two buildpacks should be consolidated into one. This buildpack should install
the ASP.NET Core Runtime dependency hosted by Microsoft. It should run its
build phase *after* application source code is compiled.

## Motivation

Currently, the .NET Core language family buildpack contains three component
buildpacks that are responsible for installing parts of the .NET toolchain. The
.NET Core SDK buildpack installs the .NET Core SDK hosted by Microsoft and
makes it available at build time.  It's used for compiling application source
code. The .NET Core Runtime buildpack installs a version of the .NET Core
Runtime hosted by the Paketo dep-server. It constructs a.NET installation and
makes it available to framework-dependent apps at launch time. The .NET Core
ASP.NET buildpack installs a version of ASP.NET Core that is hosted by the
Paketo dep-server. This dependency is a *subset* of the dependency hosted by
Microsoft. Microsoft's version contains _both_ the .NET runtime and ASP.NET
Core. The .NET Core ASP.NET buildpack adds its dependency to the makeshift .NET
installation.  In other words, for most buildpack builds, the .NET Runtime and .NET
ASP.NET buildpacks collaborate to recreate the ASP.NET Core dependency that
Microsoft hosts and ships. Both buildpacks install their dependencies in layers
**before** application source code is compiled. They come before the
`dotnet-publish` buildpack in the composite buildpack's [order
groups](https://github.com/paketo-buildpacks/dotnet-core/blob/565c719806588daaeca96e0bfd64d5743656a046/buildpack.toml).

The decision to stitch together a .NET installation was motivated by a desire to build
images with the absolute minimal number of dependencies in them; some .NET apps
don't require ASP.NET, and the current implementation builds these apps into
images that exclude ASP.NET. This saves a few megabytes on image size. But
feedback from .NET buildpack users suggests that this optimization isn't
particularly useful. Most apps built with the .NET buildpack are web apps that
need ASP.NET.

Before [RFC
0004](https://github.com/paketo-buildpacks/rfcs/blob/2ad006cd21cb3fa97026ce28328f587c6dded664/text/dotnet-core/0004-extend-dotnet-sdk.md)
was implemented, the.NET Runtime and .NET ASP.NET buildpacks had to run before
the .NET Publish buildpack because they provided build-time dependencies. Now,
they only provide launch dependencies.

There are several drawbacks to the current implementation:
1. .NET maintainers must maintain two buildpacks where one could accomplish
the same result
1. The two buildpacks must be released in lockstep, as they install
dependencies whose versions must be identical.
1. Paketo builds and hosts two dependencies (.NET Runtime, .NET ASP.NET),
while Microsoft hosts a dependency (ASP.NET) that contains all the same bits.
1. It is hard to tell during detection whether or not an application will
require ASP.NET once it's been compiled. There are myriad ways to specify
that an app should be self-contained.  Sometimes, the buildpack installs
these dependencies when they are not ultimately needed in the run image. See
https://github.com/paketo-buildpacks/dotnet-execute/issues/314.
1. Since neither the Paketo-hosted .NET Runtime nor ASP.NET dependencies
contain the `dotnet` CLI, if an app is compiled as a framework-dependent
deployment, the entire .NET SDK must be included in the app image. Meanwhile,
the ASP.NET dependency hosted by Microsoft also includes `dotnet`.

This RFC proposes that we consolidate the .NET Runtime and ASP.NET buildpacks
and install the Microsoft-hosted ASP.NET dependency. This will simplify version
resolution, reduce the number of buildpacks in the language family, and avoid
ever including the .NET SDK at launch time. The RFC also proposes that the new
ASP.NET buildpack run its build phase after source code apps have been
compiled. It can use the `runtimeconfig.json` of compiled apps to establish
whether ASP.NET is needed at launch time.

## Implementation

The .NET Runtime buildpack should be archived.

The ASP.NET buildpack should be archived.

A new buildpack should be created, called .NET Core ASP.NET Runtime
(`dotnet-core-aspnet-runtime`).  This mimics the name of the dependency as it is provided
by Microsoft. This buildpack should `provide` `dotnet-core-aspnet-runtime`.  If
`BP_DOTNET_FRAMEWORK_VERSION` is set, it should require
`dotnet-core-aspnet-runtime` with that version. Otherwise, it should require
nothing. At build time, the buildpack should look for a `*runtimeconfig.json`.
If no .NET runtimes are listed in the `*runtimeconfig.json`, the app is
self-contained, and the build phase is a no-op. No dependency should be
installed. If a runtime is listed, the buildpack should add a
`dotnet-core-aspnet-runtime` Buildpack Plan requirement for that version. It
should then do dependency resolution including roll-forward logic and install a
version of the dependency into a layer. It should mark the layer for `launch`
and add the layer to the launch-time `PATH`. This will make the .NET
installation in the layer available to run framework-dependent deployments.

The .NET Execute buildpack should `require` `dotnet-core-aspnet-runtime` at
launch time for source code applications. It should not require a specific
version. If the app is precompiled (meaning it has a `*.runtimeconfig.json`),
the buildpack should `require` `dotnet-core-aspnet-runtime` with the `version`
specified in the `*.runtimeconfig.json`. The buildpack should continue
requiring `node` when it's needed.

With these changes, the buildpacks will no longer need to use the
`RUNTIME_VERSION` environment to coordinate installing compatible versions of
.NET dependencies. The buildpacks will also no longer need to set
`DOTNET_ROOT`, since a working .NET installation will be present on the `PATH`.

The updated order groups for the .NET Core language family buildpack will be as
follows:
```toml
[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true
    version = "1.2.3"

  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true
    version = "1.2.3"

  [[order.group]]
    id = "paketo-buildpacks/dotnet-core-sdk"
    optional = true
    version = "1.2.3"

  [[order.group]]
    id = "paketo-buildpacks/icu"
    optional = true
    version = "1.2.3"

  [[order.group]]
    id = "paketo-buildpacks/node-engine"
    optional = true
    version = "1.2.3"

  [[order.group]]
    id = "paketo-buildpacks/dotnet-publish"
    optional = true
    version = "1.2.3"

  [[order.group]]
    id = "paketo-buildpacks/dotnet-core-aspnet-runtime"
    optional = true
    version = "1.2.3"

  [[order.group]]
    id = "paketo-buildpacks/dotnet-execute"
    version = "1.2.3"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    optional = true
    version = "1.2.3"

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true
    version = "1.2.3"

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true
    version = "1.2.3"
```

Note that with the proposed changes, it's possible to simplify the .NET Core
composite buildpack into one order group with several optional buildpacks.
dotnet-core-sdk and dotnet-publish are optional for precompiled apps.
dotnet-core-aspnet-runtime is optional for self-contained apps.

## Prior Art

* [Restructure spike led by @fg-j uses the .NET ASP.NET Runtime from
  Microsoft](https://github.com/paketo-buildpacks/dotnet-core/pull/727)

## Alternatives

### Keep two buildpacks, make the dependencies bigger
This would entail keeping a `dotnet-core-runtime` buildpack and a
`dotnet-core-aspnetcore` buildpack however the dependency for both of the
buildpacks would be identical to the ones provided by Microsoft on their
download page. To lay out what that means, the Runtime dependency provided by
Microsoft has all of the required libraries for an app that requires just the
runtime, as well as the .Net CLI. The ASP.NET Core dependency provided by
Microsoft has all of the same libraries, the Runtime dependency plus the
ASP.NET Core libraries. What this would mean is that we could require
`dotnet-core-runtime` **or** `dotnet-core-aspnet` we would no longer need to
require both in the case of an app needing ASP.NET core because the dependency
would be self contained.

#### Pros
- Makes is possible to use Microsoft provided dependencies with no modification
- Keeps a separation allowing for users with apps that just require the runtime
  to only have the runtime bits
- Gets rid of complicated symlinking and orchestration logic
- Removes version resolution interlock between the two buildpacks
#### Cons
- Increases the size of the offline buildpack because many of the same library bits are in multiple dependencies
- There appears to be little to no demand for this kind of granularity
