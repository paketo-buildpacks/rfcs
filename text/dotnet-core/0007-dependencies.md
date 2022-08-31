# Decide Which .NET Dependencies Will Be Paketo-hosted

## Proposal

The following dependencies should be kept as Paketo-hosted dependencies:
* [ICU](https://github.com/paketo-buildpacks/icu/blob/main/buildpack.toml)


The following dependencies should be removed as Paketo-hosted dependencies:
* [.NET Core SDK](https://github.com/paketo-buildpacks/dotnet-core-sdk/blob/main/buildpack.toml)

The following will be a new dependencies that are not currently Paketo-hosted
and should not be added:
* .NET Core ASP.NET Core Runtime
* [vsdbg](https://github.com/paketo-buildpacks/vsdbg/blob/main/buildpack.toml)

## Rationale

### ICU

Keep this as a Paketo-hosted dependency.

ICU currently [only builds for one version of
Ubuntu](https://github.com/unicode-org/icu/releases/tag/release-71-1) therefore
in order to support a wide range of stacks we should continue to compile and
host this independent of upstream. The current build process can be seen
[here](https://github.com/cloudfoundry/buildpacks-ci/blob/7c76257aa285bf148767a14dd62953b1f0b163b0/tasks/build-binary-new/builder.rb#L462).

Currently ICU uses `dep-server`, `binary-builder`, and `buildpacks-ci` to
build, but language family maintainers will transition this to the new Github
Action workflow once that has been approved.

### .NET Core SDK

Remove the Paketo-hosted dependency.

It looks like .NET Core SDL is downloaded directly from a Microsoft by scanning
their [release
index](https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json)
and using the information given on the version release pages to find an
official Microsoft release URL. Currently the .NET SDK [upload workflow
directly uploads the artifact from
Microsoft](https://github.com/paketo-buildpacks/dep-server/blob/d7402591d0581a5019b1bd620ed1367d5f155213/.github/data/dependencies.yml#L27).
Therefore, this RFC proposes removing the .NET SDK as a Paketo-hosted
dependency.

### .NET Core ASP.NET Core Runtime

This is contingent on the implmentation of [.NET RFC
0006](https://github.com/paketo-buildpacks/rfcs/blob/1d615afaa355f235b216a8fa9346d227299b388f/text/dotnet-core/0005-simplify-runtime-dependency.md)
in which we will start to consume the .NET Core ASP.NET Core Runtime as it is
provided by Microsoft. This will be achieved in the same wat as the .NET Core
SDK was the release index leads to a release page that also contains the URLs
for the Microsoft hosted dependnecy.

### vsdbg

The Microsoft [approved
way](https://docs.microsoft.com/en-us/dotnet/iot/debugging?tabs=self-contained&pivots=vscode#install-the-visual-studio-remote-debugger-on-the-raspberry-pi)
of downloading the .NET debugger is to use a script that can be obtained at
aka.ms/getvsdbgsh. This is a domain that is owned by Microsoft and therefore
relatively trustworthy. Using this script we can download the `vsdbg`
dependency, however for the purposes of the buildpack we cannot use the script
directly as that would not support an offline build.

To work around this we can use that script in our workflow to download the
latest version of the `vsdbg` and examine the version that is downloaded
through the `version.txt` file that is packaged with the dependency. Once we
have that version we can construct a static URI for that version to be used by
the buildpack.
