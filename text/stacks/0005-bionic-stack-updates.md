# Updates to Stacks based on Ubuntu Bionic

## Summary

The [Stacks RFC
0004](https://github.com/paketo-buildpacks/rfcs/tree/main/text/stacks) around
Jammy Jellyfish support in Paketo Stacks was recently merged in and contains
some naming and organizational changes that deviate from what we do for Bionic.
This RFC outlines changes we should make to the Bionic Stacks for consistency.

## Motivation

We will continue to support Bionic-based stacks until Canonical stops
supporting Bionic in March 2023, as well as introduce support for Jammy
Jellyfish-based stacks soon. Standardizing on conventions across both sets of
stacks will help with maintainability, discoverability, and usability. Without
changes outlined in this RFC, both sets of stacks would suffer from slightly
different naming, tagging, and repository locations.

## Detailed Explanation

### CNB Stack Images Only

In Stacks RFC 0004, support for non-CNB stack images was dropped for Jammy
stacks. We currently ship the Bionic stacks with both a `-cnb` suffixed option,
which contains CNB metadata to make it a valid "CNB stack image", as well as
another stack without the `-cnb` suffix and without the metadata. This meant
for each stack image we published the following set of tags:
```
paketobuildpacks/build:<version>-full-cnb
paketobuildpacks/build:<version>-full
paketobuildpacks/build:full-cnb
paketobuildpacks/build:full

paketobuildpacks/run:<version>-full-cnb
paketobuildpacks/run:<version>-full
paketobuildpacks/run:full-cnb
paketobuildpacks/run:full
```

This was originally done to make it easier for users to build on top of our
stack images without having the added CNB-official image metadata. However,
supporting two versions of the almost-identical stacks introduces unecessary
overhead, since users could still build on top of of the CNB stack.

In the Bionic stacks, we should support CNB-approved stack images ONLY, and
drop support for the intermediate images entirely.

For completeness, we should ship the same stack image to both the `-cnb`
labeled tag and as the non`-cnb` tag.

### Image Naming and Tagging

The Bionic based stacks name and tag their release images with the following pattern right now:
```
paketobuildpacks/{phase}:{version}-{variant}
```
In practice this, for the Full stack for example, this looks like:
```
paketobuildpacks/build:1.3.39-full-cnb
paketobuildpacks/run:1.3.39-full-cnb
```

The Jammy Stacks wil be following the following pattern instead, in order to
better align the image repository references in their stack definition:
```
paketobuildpacks/{phase}-jammy-{variant}:{version}
```

In an effort to standardize but maintain backwards-compatibility, we should
begin publish our Bionic-based stacks to both the "old" naming/tagging
structure outlined at the top, as well as the "new" structure that the Jammy
stacks follow.

In practice, this will mean we will publish our Bionic stacks with two naming
schemes, plus the additional `-cnb` suffixed location as outlined in the "CNB
Stack Images Only" section:
```
paketobuildpacks/{phase}:{version}-{variant}
paketobuildpacks/{phase}:{version}-{variant}-cnb
paketobuildpacks/{phase}-bionic-{variant}:{version}
```

For the Full Bionic stack, this will mean publishing:
```
paketobuildpacks/build:1.3.39-full-cnb
paketobuildpacks/build:1.3.39-full
paketobuildpacks/build:full-cnb
paketobuildpacks/build:full
paketobuildpacks/build-bionic-full:1.3.39

paketobuildpacks/run:1.3.39-full-cnb
paketobuildpacks/run:1.3.39-full
paketobuildpacks/run:full-cnb
paketobuildpacks/run:full
paketobuildpacks/run-bionic-full:1.3.39
```
Additionally, each Bionic stack README should outline the stacks that are
available, the tags available, and include links to each other repository
allowing users to discover the stack variants available from any of the stack
repository pages.

### Repositories

In keeping with what's outlined for the Jammy Stacks, we should move our Bionic
stacks over to new repositories that follow the same naming structure:

* `bionic-base-stack`
* `bionic-full-stack`
* `bionic-tiny-stack`

Each of these repos will contain the configuration for its variant of the stack
as well as the releases and their related artifacts. We can get rid of the old
`<variant>-stack-release` repositories once these repositories are set up and
automation is in place to keep releases rolling out.

## Rationale and Alternatives

We could leave the Bionic stacks as is, and roll out changes to the Jammy
stacks only, since we have less than 12 months left supporting both.

## Prior Art

* [Stacks RFC 0004](https://github.com/paketo-buildpacks/rfcs/tree/main/text/stacks)
* [`stacks`](https://github.com/paketo-buildpacks/stacks)


## Edits

EDIT 07/28/2022: Add in the legacy unversioned `<variant>-cnb` and `<variant>`
locations to push the images to as well.
