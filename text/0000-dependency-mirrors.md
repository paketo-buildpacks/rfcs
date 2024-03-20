# Easy Dependency Mirrors

## Summary

Presently, you can either take the dependencies shipped with a Paketo buildpack or you can create a whole bunch of [dependency mapping bindings](https://paketo.io/docs/howto/configuration/#dependency-mappings) to change each dependency you want to override individually. There is no option to override all dependencys and point them to a mirror that is convenient.

## Motivation

1. Managing lots of dependency bindings is tedious and a frequent pain point, so much so that there are now [tools](https://github.com/dmikusa/binding-tool) to help generate and manage these.

2. Managing lots of dependency bindings does not scale because you need to keep them up-to-date, but you can't easily know when new dependencies are updated. You also need to specify them per-application. There's no way to override this at a broader scale.

3. For operations teams, this is particularly difficult because networks may not allow access to external repositories. This forces them to either build sets of custom buildpacks with different dependency data, or manage lots of binding files.

## Detailed Explanation

This RFC proposes a standard interface that would allow a user to specify a mirror repository from which buildpacks can easily, and safely download dependencies.

When a user wants to use a dependency mirror, the user can signal that to Paketo buildpacks in two ways:

1. Set the `BP_DEPENDENCY_MIRROR` environment variable where the value is the mirror URI.
2. Include a binding with a type of `dependency-mirror`. The binding has key of `uri` and a value that is the mirror URI.

The environment variable is more convenient but we need to support bindings as well because some repositories may require basic authentication credentials in the URLs (i.e. URL includes secrets). If both happen to be defined, then the environment variable takes precedent.

The format of the URI is: `<scheme>://[<username>:<password>@]<hostname>[:<port>][/<prefix>]`

- The URL can have either a scheme of `https://` or `file://`. We specifically will not allow `http://` because this could introduce a way for a downgrade attack (i.e. someone tricks the user to downgrade from `https` to `http`).
- If a path is specified on the URL, it prefixes the original path of the dependency. This is necessary in some cases where a mirror is hosting many different repositories.
- The prefix path may include a place holder of `{originalHost}` which is substituted for the original host value. Again, this is to support mirrors that host many different repositories, which in some cases include the original hostname in the path.

When a mirror is specified the buildpack will take the data from the URL and use that to override parts of the original URL.

- The mirror scheme overrides the original scheme
- The mirror user/password overrides the original user/password
- The mirror host overrides the original host
- As mentioned above, the path from the mirror is prefixed onto the original URL path

For example, a mirror URL of `https://user:pass@local-mirror.example.com/buildpacks-dependencies/{originalHost}` would translate to look up resources as follows:

- The dependency URL of `https://download.bell-sw.com/vm/22.3.5/bellsoft-liberica-vm-core-openjdk11.0.22+12-22.3.5+1-linux-amd64.tar.gz` would be translated to `https://user:pass@local-mirror.example.com/buildpacks-dependencies/download.bell-sw.com/vm/22.3.5/bellsoft-liberica-vm-core-openjdk11.0.22+12-22.3.5+1-linux-amd64.tar.gz`.
- The dependency URL of `https://github.com/watchexec/watchexec/releases/download/v1.25.1/watchexec-1.25.1-x86_64-unknown-linux-musl.tar.xz` would be translated to `https://user:pass@local-mirror.example.com/buildpacks-dependencies/github.com/watchexec/watchexec/releases/download/v1.25.1/watchexec-1.25.1-x86_64-unknown-linux-musl.tar.xz`.

## Rationale and Alternatives

- You can clone a buildpack, modify `buildpack.toml`, then repackage it. Repeat this for every buildpack you need. Repeat it every time we release a new buildpack.
- You can clone a buildpack and then repackage it in offline mode. This downloads the dependencies and bundles them within the image. Repeat this for every buildpack you need. Repeat it every time we release a new buildpack. Plus image sizes become gigantic, multiple GB.
- You can generate a lot of dependency mapping bindings. This can work OK in small situations, but doesn't scale well in large orgs and teams. It is also difficult to keep up with over time as buildpacks update and include new dependencies.
- You can install dependencies through some other means, like preinstall them onto the build/run images.

## Implementation

Most of this is covered in the detailed explanation above, but breaking it down a bit more concretely.

We need to update both libpak and packit, both of which implement dependency downloads. The logic for both should be similar as they are both written in Go. The [libpak implementation](https://github.com/paketo-buildpacks/libpak/pull/315) has already been done as an initial discussion and reference implementation.

That should be it. Individual buildpacks don't need to change beyond updating to a version of libpak or packit that includes the implementation of this RFC.

## Prior Art

The Cloud Foundry Java Buildpack has similar mechanisms that allow a user to override the location from which it fetches dependencies. This allows users to mirror dependencies on network. It has some additional functionality that's not being proposed here, which is the ability to actually change what dependencies are included.

The proposal here would require a user to make a full mirror of the official dependency set and host that. You could, in theory, host a subset of the mirror, but there is nothing that would stop the buildpack from attempting to download dependencies that you've not mirrored. In that case, the build would fail with a download error. That use case is out of scope for this RFC.

## Unresolved Questions and Bikeshedding

It is not clear if it would be helpful to support having a mirror that refers to `http://localhost`. As this RFC is presently defined, that would not work because `https` is strictly required. One could in theory generate a TLS public/private key pair and use that to provide `https://localhost`, but it is unclear if even that would be useful.

The buildpacks run within a container and so `localhost` refers to the network in the actual container where it's very unlikely that a mirror would be running.

The reference implementation has [added specific provisions to ignore TLS certificate verification](https://github.com/paketo-buildpacks/libpak/pull/315/files#diff-625820113ce65f5b34f51f253e0de063c353a0e5ef82c7e49b898e1100a81ddcR339-R344) for `https://localhost` so that one could potentially do this, even though it doesn't seem practical.

Other options would be to not do anything, in which case `http://localhost` is forbidden because it's http-only and `https://localhost` is forbidden because certificates would not verify, or to specifically allow an exception for `http://localhost` but not http-only for any other domains.
