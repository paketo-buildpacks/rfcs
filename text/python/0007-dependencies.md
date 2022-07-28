# Decide which Python dependencies will be Paketo-hosted

## Proposal

Currently four Python buildpacks have Paketo-hosted dependencies.
Only two Paketo-hosted dependencies should be kept, and two Paketo-hosted dependencies 
should be removed in favor of consuming the upstream-provided dependency.

| Buildpack                                                                        | Action |
|----------------------------------------------------------------------------------|--------|
| [cpython](https://github.com/paketo-buildpacks/cpython/blob/main/buildpack.toml) | Keep   |
| [poetry](https://github.com/paketo-buildpacks/poetry/blob/main/buildpack.toml)   | Remove |
| [pip](https://github.com/paketo-buildpacks/pip/blob/main/buildpack.toml)         | Keep   |
| [pipenv](https://github.com/paketo-buildpacks/pipenv/blob/main/buildpack.toml)   | Remove |

### Offline not supported

Note that the Python language family does not support a fully-offline case, since several of its components require internet connectivity to work.
These include at least the following: 

* pipenv: [#limitations](https://github.com/paketo-buildpacks/pipenv#limitations)
* poetry: [#known-issues-and-limitations](https://github.com/paketo-buildpacks/poetry#known-issues-and-limitations)

## Rationale

### CPython

Keep this as a Paketo-hosted dependency.

Currently this uses `dep-server`, `binary-builder`, and `buildpacks-ci` to build, but language family maintainers
will transition this to the new Github Action workflow once that has been approved. Due to the complexity of the current
build process, this RFC does not propose removing this as a Paketo-hosted dependency.

### Poetry

Remove the Paketo-hosted dependency.

This dependency seems to be the result of a `pip download` command as seen in [buildpacks-ci](https://github.com/cloudfoundry/buildpacks-ci/blob/6e8873b5a1535c2faf56f810fde7063864db7585/tasks/build-binary-new/builder.rb#L98-L122).
This could easily be replicated in the buildpack's `build` stage.

As of 2022-06-28, this buildpack is actually not using the dependency from its `buildpack.toml`.
Instead, the buildpack is running `pip download poetry==$VERSION`, see its [source code](https://github.com/paketo-buildpacks/poetry/blob/ca9e73b34d7018ce00f7d75c76382a08df554a41/poetry_install_process.go#L35).

This RFC does not require Python maintainers to incorporate all logic from `buildpacks-ci` into the `poetry` buildpack.

Also, see [Offline not supported](#offline-not-supported).

In order to achieve build reproducibility, the `poetry` buildpack will include `metadata.default-versions` in `buildpack.toml`
that will default the version installed. A new github workflow for this buildpack will keep `metadata.default-versions` up to date in a timely manner.

This RFC does not propose any changes to the layer reuse strategy currently employed by the `poetry` buildpack.
The changes outlined above do allow application developers to update `poetry`'s transitive dependencies by clearing the lifecycle cache
using something like `pack build --clear-cache` which will download `poetry` from upstream with its latest transitive dependencies.

#### Poetry SBOM

The SBOM would be generated from the directory into which `poetry` and its related dependencies are installed.
This is supported by Syft.

### pip

Keep this as a Paketo-hosted dependency.

While installing `pip` involves using `pip` itself to install the desired version, there's quite a bit of prerequisites and setup required.
See [buildpacks-ci](https://github.com/cloudfoundry/buildpacks-ci/blob/master/tasks/build-binary-new/builder.rb#L32-L63).

Language family maintainers will transition this to the new Github Action workflow once that has been approved.

### pipenv

Remove the Paketo-hosted dependency.

This dependency seems to be the result of a `pip download` command as seen in [buildpacks-ci](https://github.com/cloudfoundry/buildpacks-ci/blob/6e8873b5a1535c2faf56f810fde7063864db7585/tasks/build-binary-new/builder.rb#L65-L96).
This could easily be replicated in the buildpack's `build` stage.

As of 2022-06-28, this buildpack is actually not using the dependency from its `buildpack.toml`.
Instead, the buildpack is running `pip download pipenv==$VERSION`, see its [source code](https://github.com/paketo-buildpacks/pipenv/blob/9b6c759713d5fac12e26905f0850a2647cd1e76d/pipenv_install_process.go#L35).

This RFC does not require Python maintainers to incorporate all logic from `buildpacks-ci` into the `pipenv` buildpack.

Also, see [Offline not supported](#offline-not-supported).

In order to achieve build reproducibility, the `pipenv` buildpack will include `metadata.default-versions` in `buildpack.toml`
that will default the version installed. A new github workflow for this buildpack will keep `metadata.default-versions` up to date in a timely manner.

This RFC does not propose any changes to the layer reuse strategy currently employed by the `pipenv` buildpack.
The changes outlined above do allow application developers to update `pipenv`'s transitive dependencies by clearing the lifecycle cache
using something like `pack build --clear-cache` which will download `pipenv` from upstream with its latest transitive dependencies.

#### pipenv SBOM

The SBOM would be generated from the directory into which `pipenv` and its related dependencies are installed.
This is supported by Syft.
