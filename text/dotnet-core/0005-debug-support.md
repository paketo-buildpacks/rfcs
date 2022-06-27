# Enable Remote Debug Support

## Proposal

The .NET Core buildpack should enable remote debugging of applications in a
manner that conforms to [Project
RFC0037](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0037-remote-debug.md).
To accomplish this, the buildpack will need to install the Visual Studio
Debugger into the application run image. The debugger can attach to a running
`dotnet` process and be bound to a client-side debugger via STDIN across a
connection invoked via `docker exec` or `kubectl exec`.

## Motivation

Remote debugging is a useful practice for understanding complex program logic
and interactions in remote environments including production. Providing this
feature for .NET Core developers will bring this buildpack into alignment with
the types of features we already provide for developers in other language
families like Java.

## Implementation

Implementing this feature will require changes in 2 existing buildpacks,
`dotnet-publish` and `dotnet-execute`, and the addition of a new buildpack,
`vsdbg`, to the `dotnet-core` language-family buildpack.

### `vsdbg`

This buildpack will be developed to enable the installation of the Visual
Studio Debugger into application run images. It will essentially implement the
steps shown in [this
documentation](https://github.com/Microsoft/MIEngine/wiki/Offroad-Debugging-of-.NET-Core-on-Linux---OSX-from-Visual-Studio#linux-computer)
to install the `vsdbg` tool.

This buildpack will provide `vsdbg` in its build plan.

### Changes to `dotnet-execute`

The `dotnet-execute` buildpack will have its detect phase modified to look for
the `BP_DEBUG_ENABLED` environment variable. If this variable is set to `true`,
the buildpack will require `vsdbg` in its build plan with `launch = true` set
in the metadata. It will also set `ASPNETCORE_ENVIRONMENT=Development` to
conform to the recommendations in the [documentation regarding debugging in
containers](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/visual-studio-tools-for-docker?view=aspnetcore-6.0#debug).

### Changes to `dotnet-publish`

The `dotnet-publish` buildpack currently runs the following command in its build process:

```
dotnet publish \
  --configuration Release \
  --runtime ubuntu.18.04-x64 \
  --self-contained false \
  --output <output-path>
```

When the `BP_DEBUG_ENABLED` environment variable is set to `true`, the
buildpack will set the `--configuration` flag to `Debug` to ensure debug
support is built into the compiled application.

### Changes to the `dotnet-core` buildpack

In the `dotnet-core` buildpack, the `vsdbg` buildpack will be added to each
order group. The buildpack should be specified as `optional = true` and must
appear in the order prior to the `dotnet-execute` buildpack.

### What happens during build?

When `BP_DEBUG_ENABLED` is set to `true`, the following will take place:

1. `dotnet-execute` buildpack will require `vsdbg` for `launch` in its build plan
1. `vsdbg` will install the Visual Studio Debugger on the `$PATH`
1. `dotnet-publish` buildpack will ensure the application is built with debug configuration
1. `dotnet-execute` buildpack will set the `ASPNETCORE_ENVIRONMENT` environment variable to `Development`

## Source Material

* [Offroad Debugging of .NET Core on Linux OSX from Visual Studio](https://github.com/Microsoft/MIEngine/wiki/Offroad-Debugging-of-.NET-Core-on-Linux---OSX-from-Visual-Studio)
