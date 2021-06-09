# Semantic Versioning of Buildpacks and Builders

## Summary

All Paketo buildpack releases use the semver syntax for versioning, but does
not necessarily follow semver semantics.

The [CNB Buildpacks spec](https://github.com/buildpacks/spec/blob/buildpack/v0.6/buildpack.md) says:

> The buildpack version:
>
> - MUST be in the form <X>.<Y>.<Z> where X, Y, and Z are non-negative integers and must not contain leading zeros.
>    - Each element MUST increase numerically.
>    - Buildpack authors will define what changes will increment X, Y, and Z.


It does not define what changes will increment the Major (`X`), Minor (`Y`) and Patch (`Z`) versions
of buildpack releases.

This RFC attempts to set guidelines and good practices for versioning of Paketo
Buildpacks, Builders and Stacks so that authors and consumers can rely on a
consistent standard of versioning.

## Table of Contents

  * [Summary](#summary)
  * [Motivation](#motivation)
  * [Semantics](#semantics)
     * [Changes](#changes)
        * [Buildpack (General)](#buildpack-general)
        * [Buildpack Dependencies](#buildpack-dependencies)
        * [Composite Buildpack](#composite-buildpack)
        * [Builder](#builder)
        * [Stack](#stack)
     * [Intial Development](#intial-development)
  * [User Policy](#user-policy)
     * [Critical security updates](#critical-security-updates)
  * [Process](#process)
  * [What this is not?](#what-this-is-not)

## Motivation

As a Buildpack/Builder maintainer,<br/>
I need a release versioning guideline,
so I can make my release versions consistent.

As a Buildpack/Builder user,<br/>
I want to know how versioning is done,
so I can use the appropriate version and
decide when to upgrade.

As a Buildpack/Builder user,<br/>
I want versioning to be consistent across all Paketo buildpacks
so I don't have to understand multiple policies.

## Semantics

Semantic Versioning 2.0.0 defines versioning syntax as follows ([semver.org](https://semver.org/)):

> Given a version number MAJOR.MINOR.PATCH, increment the:
> 
>   - MAJOR version when you make incompatible API changes,
>   - MINOR version when you add functionality in a backwards compatible manner, and
>   - PATCH version when you make backwards compatible bug fixes.

The proposal is to conform to the above semantics as much as possible.

### Changes

In terms of Paketo Buildpacks/Builders, this translates to:

* Bumping MAJOR is analogous to an "`app or related buildpacks is likely to not
	work without change`" relation between releases.
* Bumping MINOR is analogous to an "`updates or adds features`" relation
	between releases.
* Bumping PATCH is analogous to a "`fixes issue`" relation between releases.

The following table lists the usual circumstances/events where bumping a particular component is expected:

#### Buildpack (General)
| `Major` | `Minor` | `Patch` |
|-|-|-|
| \<Any incompatible change\> | \<Feature additions but compatible with previous release\> | \<Fixes but no major feature changes\> |
| Change in Buildpack ID | Support for a new stack | Bug fixes |
| Change in Buildpack API version | Buildpack runs a new command the causes backward compatible<br>change in behavior (e.g. x-install buildpack adds running "x clean") | Performance improvement, internal tweaks |
| Change in Build Plan API (Provides/Requires) | New configuration option (e.g. new environment variable support) | CVE fixes |
| Removal of a stack | Change in <br>[buildpack-specific metadata](https://github.com/buildpacks/spec/blob/buildpack/v0.6/buildpack.md#build-plan-toml) | Change of required build tool version to package buildpack<br>(e.g. go version) |
| Removal of configuration options<br>(e.g. buildpack.yml) | Deprecation of a stack or configuration option |  |
<br/>

#### Buildpack Dependencies

For buildpacks whose primary function is to provide dependencies, the following versioning is expected
when versions of dependencies are added or removed. The table below assumes that upstream dependencies
follow [semantic versioning](https://semver.org/). For those that do not, maintainers may determine
their versioning independently.

| Dependency change | Buildpack Version expectation |
|-|-|
| **ADD** |  |
|    - Patch | Bump Patch |
|    - Minor | Bump Minor |
|    - Major | Bump Minor |
| **REMOVE** |  |
|    - Patch | Bump Patch |
|    - Minor | Bump Minor |
|    - Major | Bump Major |
| **CHANGE DEFAULT** |  |
|    - Patch<br>     (e.g. 1.0.0 -> 1.0.1) | Bump Patch |
|    - Minor<br>     (e.g. 1.0.1 -> 1.1.0) | Bump Minor |
|    - Major<br>     (e.g. 1.1.1 -> 2.0.0) | Bump Major |
<br/>


#### Composite Buildpack
| `Major` | `Minor` | `Patch` |
|-|-|-|
| Implementation buildpack major bumps<br>causing breaking change in behavior | Implementation buildpack minor bumps | Implementation buildpack patch bumps |
| Removal of an order group dropping<br>support of some workflow | Addition of an order group that do<br>not cause change in detection logic |  |
| Swapping order of order groups | Addition of a component buildpack |  |
| Addition of an order group<br>causing change in detection logic |  |  |
| Removal of a component buildpack |  |  |
<br/>


#### Builder
| `Major` | `Minor` | `Patch` |
|-|-|-|
| Lifecycle major bumps | Minor bumps of components | Patch bumps of components |
| Stack Image major bumps | Addition of a buildpack<br>as last in the order |  |
| Buildpack major bumps |  |  |
| Change in Stack ID |  |  |
| Removal of a Buildpack |  |  |
| Swapping order of buildpacks |  |  |
| Addition of a buildpack except<br>as last in the order |  |  |
<br/>

#### Stack
| `Major`                 | `Minor`                   | `Patch`                   |
|-------------------------|---------------------------|---------------------------|
| Removal of  a package   | Addition of a new package | Update of a package       |

### Intial Development

A version of `0.0.z` is considered to be experimental/unstable and may not be
suitable for user consumption. All changes will be released as patches.

A version of `0.y.z` is considered to be in initial development and ready for
feedback from early adopters. Anything may change at any time. All breaking changes
will be released as minor bumps.

\* `y`, and `z` are non-negative integers.

## User Policy

* **Patch** bump: User should update their buildpack/builder without
	hesitation.

* **Minor** bump: User can update their buildpack/builder to avail new
	features. Nothing will break if buildpack-set default dependency versions are
	not overridden.

* **Major** bump: Users must review changelog and test build system on update.
	May contain breaking changes.


### Critical security updates

If a user is on the latest `Major` and `Minor` versions, critical security
updates when they occur should be available for users on the latest `Patch`
version.

## Process

This section proposes a process that will help maintainers easily determine
whether a given change or a set of changes require a bump in the major, minor,
or patch component.

* Changes should be accepted to the main line of code only via Pull Requests.

* All Pull Requests (including automated PRs by the
  [paketo-bot](https://github.com/paketo-bot)) must be tagged with either of
  the 3 labels:
	* `semver:major` - denoting accepting the change will require a major
	  version bump in the next release.
	* `semver:minor` - denoting accepting the change will require a minor
	  version bump in the next release.
	* `semver:patch` - denoting accepting the change will require a patch
	  version bump in the next release.

* When releasing the next version, the maintainer must pick the most
  significant required version bump from among the accepted Pull Requests and
  bump that component of the release. The order of significance is `major` >
  `minor` > `patch`.

* Pull requests with critical security updates must be additionally tagged as
  `security-fix` and be immediately released as a patch version.

## What this is not?

These are not strict rules - simply guidelines.  There's no promise of
infallible, always pain-free, fully-automatable updates.

Semantic versioning in true sense is idealistic, and does not solve all
problems with versioning.  Terms like breaking/incompatible change are
subjective dependent on specific ecosystems and domains.
