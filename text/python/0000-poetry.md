# Supporting Poetry in Python Buildpack

## Summary

The Python buildpack should support building an app with dependencies managed
with [Poetry](https://python-poetry.org/). In addition to the set of buildpacks
outlined in [RFC
0001](https://github.com/paketo-buildpacks/rfcs/blob/main/text/python/0001-restructure.md),
the Python buildpack should contain:

```
* `poetry`
  * provides: `poetry`
  * requires: `cpython` and `pip` during build

* `poetry-install`
  * provides: `poetry-venv`
  * requires: `cpython`, `pip`, and `poetry` during `build`

* `poetry-run`
  * provides: 
  * requires: `cpython`, `pip`, `poetry`, and `poetry-venv` during `build`
```

The following order grouping should be added to the Python buildpack:

```
[[order]]

  [[order.group]]
    id = "paketo-buildpacks/cpython"
    
  [[order.group]]
    id = "paketo-buildpacks/pip"

  [[order.group]]
    id = "paketo-community/poetry"

  [[order.group]]
    id = "paketo-community/poetry-install"

  [[order.group]]
    id = "paketo-community/poetry-run"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    optional = true
```

## Motivation

Poetry is one of the most popular dependency managers for Python. It provides
Python developers with tools for managing their app dependencies and virtual
environments.

## Detailed Explanation

A new buildpack order group in the Python buildpack will consist of a `poetry`,
`poetry-install` and `poetry-run` buildpack. These buildpacks will handle the
installation of Poetry itself, the installation of the app's dependencies
(using Poetry) and setting the application's start command.


## Implementation


### Buildpack Dependencies

Here is an example `buildpack.toml` from the `poetry` buildpack:

```
[metadata]
  include-files = ["bin/build", "bin/detect", "bin/run", "buildpack.toml"]
  pre-package = "./scripts/build.sh"
  [metadata.default-versions]
    poetry = "1.1.*"

  [[metadata.dependencies]]
    id = "poetry"
    name = "Poetry"
    sha256 = "some-sha256"
    source = "https://github.com/python-poetry/poetry/archive/refs/tags/1.1.6.tar.gz" # must be source code release asset for now, can optimize for space later
    source_sha256 = "some-source-sha256"
    stacks = ["some-stack"]
    uri = "some-uri"
    version = "<some-version>"
```

This would require the `poetry` dependency to be served by the
`dep-server` so that it may be consumed by the buildpack.

### Poetry Installation

The [Poetry
docs](https://python-poetry.org/docs/#osx-linux-bashonwindows-install-instructions)
recommend installing the cli using the `get-poetry.py` script in lieu of tools
like pip. On further exploration, however, it seems installing Poetry through
pip could be preferable in some cases, especially in a [container
setting](https://github.com/python-poetry/poetry/pull/3209#issuecomment-708739500).

With this in mind, the proposed installation path would entail consuming
`poetry` as a standard buildpack dependency through `buildpack.toml` as
outlined above, then installing it into a layer using the resulting dependency
artifact with `pip`. The equivalent `pip` command would resemble:

`PYTHONUSERBASE=<path/to/target/layer> pip install poetry --user --find-links=<path/to/poetry/artifact>`

#### Alternative:

It is possible that the `poetry` buildpack could download the install script
and `poetry` release artifact of a specific version to separate layers and run
the install script.  Fortunately, the `get-poetry.py` script
[supports](https://github.com/python-poetry/poetry/pull/2162) a `--file` flag
that takes the path of an archive from which to install the `poetry` cli. Thus,
the buildpack could run `python get-poetry.py --file <release-asset.tgz>` with
`POETRY_HOME=<path/to/target/layer>` set.

### Dependency Installation

By default, poetry creates virtualenvs to install dependencies into. This
[config
option](https://python-poetry.org/docs/configuration/#virtualenvsin-project),
when set to `true`, causes poetry to create a virtualenv inside the project
directory.

Once a virtualenv is created, a user might run `poetry shell` which
"activates" the virtualenv, followed by `poetry install` and `poetry
run`. This activation is less useful in the context of a running container
since the environment has already been optimally configured by the buildpacks.
The poetry-install buildpack will therefore forego the `poetry shell` step and
instead:

1. Configure poetry to create the virtualenv within the project dir
1. Run `poetry install`

The resulting virtualenv will be stored in a separate layer and symlinked into
the working directory.

### Launching an app

Unlike the existing order groups in the Python buildpack, the `poetry` group
will rely less on Procfile in favor of a more idiomatic `poetry-run` buildpack.
Poetry has its own `run` command and it seems worthwhile to sacrifice
consistency with the other Python buildpacks for a more idiomatic user
experience. The alternative would be to specify `poetry run` as part of a
process type in a Procfile.

## Prior Art

- The Miniconda buildpack downloads an installation script which installs
  `conda` [RFC000X]. To support this change, `packit` was modified to handle
  downloading text files/scripts as dependency.


## Unresolved Questions and Bikeshedding

- Where will packages be installed?
    - It does not seem that installing to a custom directory is officially
      supported yet. (Poetry Issues:
      [#2003](https://github.com/python-poetry/poetry/issues/2003) &
      [#1937](https://github.com/python-poetry/poetry/issues/1937))

- What steps are needed to enable caching with poetry?

  - In the Node.js buildpack, npm-install runs the dependency installation
    process from the working directory and moves the resulting files into a
    separate layer. This new location is subsequently symlinked to the relevant
    path within the working directory. This approach could be reused in the
    poetry-install buildpack.

  - How does the native poetry cache interact with buildpack caching?

- Should there be a poetry-run-script buildpack?

## Future Topics

- Should `poetry-install` provide `site-packages`?
