# Pip Install Architecture

## Proposal
The Pip Install buildpack will use the package installer
[pip](https://pypi.org/project/pip) to install dependencies from a
`requirements.txt` file into a layer that will be managed by the buildpack.

## Motivation
In keeping with the overarching [Python Buildpack Rearchitecture
RFC](https://github.com/paketo-community/pip/blob/main/rfcs/0001-pip-rearchitecture.md),
the Pip Install Buildpack should perform one task, which is installing from
requirements files. This is part of the effort in Paketo Buildpacks to reduce
the responsibilities of each buildpack to make them easier to understand and
maintain.

## Implementation
### API
- pip-install
  - `requires`: `cpython` and `pip` during build
  - `provides`: `site-packages`

### Detect
The pip-install buildpack should only detect if there is a `requirements.txt`
file at the root of the app.

### Build
There will be two layers, `packages` layer and `cache` layer.
The packages layer will contain the result of the pip install command.
The cache layer will hold the pip [cache](https://pip.pypa.io/en/stable/reference/pip_install/#caching).

During the build process, it will utilize the `pip` tool provided by the `pip`
requirement (e.g. provided by the `paketo-community/pip` buildpack).

The resulting build command run by the Pip Install buildpack will be:
```bash
pip install
  --requirement <requirements file>           # install from given requirements file
  --ignore-installed                          # ignores previously installed packages
  --exists-action=w                           # if path already exists, wipe before installation
  --cache-dir=<path to cache layer directory> # reuse pip cache
  --compile                                   # compile python source files to bytecode
  --user                                      # install to python user install directory set by PYTHONUSERBASE
  --disable-pip-version-check                 # ignore version check warning
```
Upgrade options are ignored if using `--ignore-installed` See [upgrade
options](https://pip.pypa.io/en/stable/development/architecture/upgrade-options/).

This should be run with the environment variable `PYTHONUSERBASE` set to the packages layer directory.

If the app has a vendor directory at the root, the app will be considered vendored and the resulting build command will be:
```bash
pip install
  --requirement <requirements file>
  --ignore-installed
  --exists-action=w
  --no-index                                   # ignore package index, uses --find-links URLs
  --find-links=<file://<app vendor directory>> # uses apps vendor directory
  --compile
  --user
  --disable-pip-version-check
```

#### Environment variables

The buildpack should attach the environment variable `$PYTHONUSERBASE` to the
`packages` layer, set its value to the layer's directory path, and make it
available during both the build and launch phases.
