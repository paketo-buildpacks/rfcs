# Python Paketo Buildpack Promotion

## Summary

A [Python Buildpack](https://github.com/paketo-community/python) exists as a
community created buildpack in the [Paketo Community
Org](https://github.com/paketo-community/python). This RFC proposes the
promotion of the Python Buildpack from a "Community" buildpack to an official
Paketo Buildpack. 

## Motivation

The community Python Buildpack has reached an initial feature completion state
and supports the most common Python app use cases and package managers (pip,
pipenv, conda etc.). The contributors of this buildpack has recently
restructured it to follow Paketo Buildpack philosophies like modularity,
meaningful API etc. (See
[RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/python/0001-restructure.md),
[Implementation](https://github.com/paketo-community/python/issues/226))  

Python is one of the most popular programming languages, and its promotion to
an official Paketo buildpack would mean that it can be exposed to a much
broader set of users via the Paketo builders. 

## Detailed Explanation

The Python Buildpack should be promoted to the `paketo-buildpacks` github org.
and considered an official language-family supported by the Paketo project. The
Python Buildpack should be included in Paketo builders (Full, Base) and
promoted in website content.

Upon promotion, future enhancements should be made from directly within the
`paketo-buildpacks` org. 

## Implementation

The following repos should be moved from the `paketo-community` to `paketo-buildpacks` Github Org:
- [Language Family Python Buildpack](https://github.com/paketo-community/python)
- [CPython Buildpack](https://github.com/paketo-community/cpython)
- [Pip Buildpack](https://github.com/paketo-community/pip)
- [Pipenv Buildpack](https://github.com/paketo-community/pipenv)
- [Pip Install Buildpack](https://github.com/paketo-community/pip-install)
- [Pipenv Install Buildpack](https://github.com/paketo-community/pipenv-install)
- [Miniconda Buildpack](https://github.com/paketo-community/miniconda)
- [Conda Env Update Buildpack](https://github.com/paketo-community/conda-env-update)
- [Python Start Buildpack](https://github.com/paketo-community/python-start)

* All Python Buildpack IDs should be updated to
	`paketo-buildpacks/<RUNTIME>`

* All Python Buildpack artifacts should be shipped to
	`index.docker.io/paketobuildpacks/<RUNTIME>` and
	`gcr.io/paketo-buildpacks/<RUNTIME>`

* All Python buildpacks will continue to be maintained by the [Python
	subteam](https://github.com/orgs/paketo-buildpacks/teams/python)

* Versioning of all buildpacks should continue as is.

* The Python Buildpack should be added to Base & Full Paketo Builders as
	described in the [Builder Detection Ordering
	RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/builders/0001-buildpack-order.md)

* Sample apps for common Python app configurations should be added to the
	[Paketo samples repo](https://github.com/paketo-buildpacks/samples)

* Python buildpack docs should be added to [Paketo
	docs](https://paketo.io/docs/buildpacks/)

* Python logo should be added to the [Paketo
	website](https://github.com/paketo-buildpacks/samples)
