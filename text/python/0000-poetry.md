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
  * provides: `site-packages`
  * requires: `cpython`, `pip`, and `poetry` during `build`
```

The following order grouping should be added to the Python buildpack:

```
[[order]]

  [[order.group]]
    id = "paketo-community/cpython"
    
  [[order.group]]
    id = "paketo-community/pip"

  [[order.group]]
    id = "paketo-community/poetry"

  [[order.group]]
    id = "paketo-community/poetry-install"

  [[order.group]]
    id = "paketo-community/python-start"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    optional = true
```

## Motivation

Poetry is one of the most popular dependency managers for Python. It provides
Python developers with tools for managing their app dependencies and virtual
environments.

## Detailed Explanation

A new buildpack order group in the Python buildpack will consist of a `poetry`
& `poetry-install` buildpack. It will handle the installation of Poetry itself
and the installation of the app's dependencies (using Poetry) respectively.


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

This would require the `poetry` dependency to be built and served by the
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

<-- WIP -->


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

    - By default, poetry creates virtualenvs to install dependencies into. This
      [config
      option](https://python-poetry.org/docs/configuration/#virtualenvsin-project),
      when set to `true`, causes poetry to create a virtualenv inside the
      project directory. It may be possible to leverage this option along to
      control where dependencies are installed.

 E.g.
    ```bash
    #!/bin/bash
    function main() {
      pip install poetry
      poetry config virtualenvs.in-project true

      local dir
      dir="/tmp/python-packages"
      ln -s "${dir}" .venv

      poetry install -vvv --no-dev --no-root
    }

    main "${@:-}"
    ```

