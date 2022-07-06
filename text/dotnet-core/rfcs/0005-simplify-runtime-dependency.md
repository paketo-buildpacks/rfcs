# Reduce Build Complexity of .Net Runtimes

## Proposal

Download the ASP.NET Core Runtime dependency provided by Microsoft instead of
combining the custom built dependencies that we are currently using.

## Motivation

Currently, in order to get the .Net buildpack to function correctly at
launchusing our custom dependencies, we need to build a somewhat convoluted
fake .Net hive that is constructed out of symlinks to dependencies on layers.
We have built these custom runtime dependencies in the past to allow for users
to only install the minimal libraries needed. After some discussion with
community members we have come to the conclusion that this level of granularity
is unnecessary. This process is also complicated to both execute and understand
and requires us to pass version information for Runtime to ASP.NET which is
clunky, is susceptible to breaking based on changes in the upstream because
this is not a supported workflow, and requires us to modify the underlying
dependency provided by Microsoft.

With the approval of the extended .NET SDK RFC there is also no longer a need
to construct a hive that can have .NET SDK bits added to it because the .NET
SDK dependency is now self-sufficient. Therefore we should install the ASP.NET
dependency as it is packaged by Microsoft becuase it comes constructed as a
valid install. The ASP.NET Runtime dependency is a superset of all runtime
libraries and includes the .NET CLI (which is needed to run Framework Dependent
Deployments). This move will also further mimic how Microsoft has their
prebuilt images configured.

## Implementation

The .NET ASP.NET Runtime dependency referenced in the buildpack should be
identical to the one provided by Microsoft. This will allow us to install a
fully realized .NET ASP.NET into a launch-only layer meaning it will not
interfere with any .NET SDK installation during build. We will archive the
`dotnet-core-runtime` and `dotnet-core-aspnet` buildpacks and create a new
`dotnet-core-aspnet-runtime` buildpack to mimic the name of the dependency as
it is provided by Microsoft.

This will mean that the buildpack will no longer need to set the
`RUNTIME_VERSION` environment variable because that information will no longer
need to be communicated between buildpacks. Also the buildpacks will no longer
need to set the `DOTNET_ROOT` environment variable as a well structured
installation will be present on the PATH.

## Prior Art

* [Restructure spike led by @fg-j uses the .NET ASP.NET Runtime from Microsoft](https://github.com/paketo-buildpacks/dotnet-core/pull/727)
