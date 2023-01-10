# Add Backwards Compatible Build Plan API in the .NET Core ASP.NET Runtime Buildpack

## Proposal

We should make the build plan of the .NET Core ASP.NET Runtime buildpack
backwards compatible so that is can fulfill the requirement of `dotnet-runtime`
and `dotnet-aspnetcore` which are the requirements of the .NET Runtime and .NET
ASP.NET buildpacks. This will allow us to archive those buildpacks and provide
users that have buildpacks that rely on the existing build plan a grace period
to upgrade their dependent buildpacks to the new build plan API. We will also
be able to warn users and advise them to upgrade buildpacks that rely on the
old build plan API.

## Motivation

We would like to encourage users to move to the new .NET Core ASP.NET Runtime
buildpack which superseded the functionality of the .NET Runtime and .NET
ASP.NET buildpacks to be able to archive those buildpacks. However, we have not
given users a more gradual upgrade path for potentially custom buildpacks that
require the build plan API from the older buildpacks. With this change we will
give users that more gradual upgrade path as well as making them aware that
there has been a change to the underlying build plan API.

Also by setting up this a backwards compatible API there should be no breaking
change for users to switch to the .NET Core ASP.NET Runtime buildpack meaning
that we can archive the the .NET Runtime and .NET ASP.NET buildpacks and remove
them as a support burden. The current support burden for this buildpack is that
it is requiring us to keep the `dep-server` running as it currently does all of
the dependency updates for the old buildpacks so by archive the old buildpacks
we should be able to remove the remaining `dep-server` workflows and begin the
process of putting it in full time maintenance mode.

## Implementation

The current build plan API is as follows:
```toml
[[provides]]
name = "dotnet-core-aspnet-runtime"
```
The following is a suggestion for a backwards compatible build plan API:
```toml
[[provides]]
name = "dotnet-core-aspnet-runtime"

[[or]]

[[or.provides]]
name = "dotnet-runtime"

[[or]]

[[or.provides]]
name = "dotnet-runtime"

[[or.provides]]
name = "dotnet-aspnetcore"
```

The backwards compatible API should be supported until the next major release
and then we can remove it after that point is reached, hopefully giving people
who use the old build plan API enough time to change their implementations.

As part of this we should warn users using the older build plan during build
that this API gateway is being removed and that they should transition their
buildpacks to requiring `dotnet-core-aspnet-runtime` instead.
