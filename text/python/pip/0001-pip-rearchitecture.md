# Pip Rearchitecture

## Proposal

The existing pip buildpack should be rewritten and restructured to *only*
provide the `pip` dependency. The `pip install` logic should be factored out
into it's own buildpack.

## Motivation

In keeping with the overarching [Python Buildpack Rearchitecture
RFC](https://github.com/paketo-community/python/blob/main/rfcs/0001-restructure.md),
the Pip Buildpack should perform one task, which is installing the `pip`
dependency. This is part of the effort in Paketo Buildpacks to reduce the
responsibilities of each buildpack to make them easier to understand
and maintain.

## Implementation

The implementation details are outlined in [this
issue](https://github.com/paketo-community/pip/issues/82). Specifically, the
new Pip Buildpack will always `detect` and  will always `provide` `pip`. It
will be the responsibility of a downstream buildpack (such as a future Pip
Install buildpack) to `require` the `pip` dependency.

The new `provides`/`requires` contract will initially be:

* `pip`
  * provides: `pip`
  * requires: `cpython` OR {`python` + `requirements`} during `build`

The {`python` + `requirements`} requirement is included for
backwards-compatibility and will be removed towards the end of the full Python
rearchitecture.


The final `provides`/`requires` contract will be:

* `pip`
  * provides: `pip`
  * requires: `cpython` during `build`

### Configuration

Users may specify a Pip version through the `BP_PIP_VERSION` environment
variable. This can be set explicitly at build time (e.g. `pack --env`) or through
`project.toml`.

### Dependency Installation

`Pip` installation involves a few steps:

Download the pip dependency and untar it to a temporary directory (we refer to this
as `<path/to/pip/dependency>` in this RFC).

The buildpack runs `PYTHONUSERBASE=<path/to/pip/layer> python -m pip
install <path/to/pip/dependency> --user --find-links=<path/to/wheel/and/setuptools>` to install the requested version. Setting the
`PYTHONUSERBASE` variable ensures that pip is installed to the newly created
layer.

The pip installation is then added to the `PATH` variable so that it may be
invoked without the `python -m` prefix.

The final step is prepending the `<path-to-pip-layer>` onto the `PYTHONPATH` and
exporting it as a shared environment variable for downstream buildpacks. This
is necessary so Python looks for `pip` in the pip layer, instead of the default
location.

(EDIT: 03/17/2021 Added Configuration and Dependency Installation sections)
(EDIT: 03/23/2021 The pip source is not a .tgz, update Dependency Installation section)
