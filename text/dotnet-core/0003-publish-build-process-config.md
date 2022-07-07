# Publish Build Process Configuration Options

## Proposal

The build process of the `dotnet-publish` buildpack should be explicitly
separated into 2 commands, `dotnet restore` and `dotnet publish`. Following
this split, each command should be configurable using either the
`BP_DOTNET_RESTORE_FLAGS` or `BP_DOTNET_PUBLISH_FLAGS` environment variables.

## Motivation

The `dotnet-publish` buildpack implementation runs the `dotnet publish` command
to build your application. This invocation is mostly hardcoded and provides
very little in the way of configurability for the buildpack user.

Adding a flag that allows user to configure the flags passed to the `dotnet
publish` command will open up more configuration options for users, however,
there are still some parts of the build process that cannot be configured
through the `dotnet publish` command flags. Specifically, those configuration
options that influence the [implicit `restore`
phase](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-publish#implicit-restore)
of the `publish` operation cannot be set directly. For cases where the user
wants more control over this command, it is expected that the command is
invoked directly, and then that the `publish` command is configured to skip the
`restore` phase.

Splitting up the build process into distinct `restore` and `publish` commands
will give our users more control over the complete build process by allowing
the buildpack to provide configuration for each command.

## Implementation

The current implementation executes the following command:

```
dotnet publish <project-path> \
  --configuration Release \
  --runtime ubuntu.18.04-x64 \
  --self-contained false \
  --output <output-path>
```

This command can be replaced by running the following commands in sequence:

```
dotnet restore <project-path> \
  --runtime ubuntu.18.04-x64

dotnet publish <project-path> \
  --configuration Release \
  --runtime ubuntu.18.04-x64 \
  --self-contained false \
  --no-restore \
  --output <output-path>

### Amendment
In attempting to implement the RFC as written, we uncovered issues with offline
builds when `dotnet restore` was split from `dotnet publish` (see
paketo-buildpacks/dotnet-publish#243).  Instead, `dotnet publish` is run
**without** the `--no-restore` flag.
```

Once the commands are separated, the buildpack can provide
`BP_DOTNET_RESTORE_FLAGS` and `BP_DOTNET_PUBLISH_FLAGS` environment variables
that will allow users to configure the arguments to each of these commands. By
default these variables should have the following settings:

* `BP_DOTNET_RESTORE_FLAGS=--runtime ubuntu.18.04-x64`
* `BP_DOTNET_PUBLISH_FLAGS=--configuration Release --runtime ubuntu.18.04-x64 --self-contained false --no-restore --output <output-path>`

The API for these environment variables should allow users to make "patch"
modifications to the default set while still retaining the other defaults. For
example, if the user wished to simply override the `--self-contained` flag,
they should only need to provide the variable as
`BP_DOTNET_PUBLISH_FLAGS=--self-contained true`. This setting would "patch" the
other settings in the default configuration to make a flag group like the
following:

```
dotnet publish <project-path> \
  --configuration Release \
  --runtime ubuntu.18.04-x64 \
  --self-contained true \
  --no-restore \
  --output <output-path>
```
### Amendment
Since `dotnet restore` was not split out from `dotnet publish`, only
`BP_DOTNET_PUBLISH_FLAGS` was implemented. The environment variable otherwise
behaves as described here.

## Source Material

* Documentation of the [`dotnet
  publish`](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-publish)
  and [`dotnet
  restore`](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-restore)
  commands
* Go Build flags
  [RFC](https://github.com/paketo-buildpacks/go-build/blob/40aac655842daa236a085b4fcb89d982894e03cc/rfcs/0002-build-flags.md)
