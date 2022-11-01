# Introduce Kerberos Buildpack

## Summary

Introduce a buildpack that installs the [MIT
Kerberos](https://kerberos.org/dist/) libraries and executables such that
applications authenticating with Kerberos can do so on any of the supported
stacks.

## Motivation

Kerberos is currently supported for applications built on top of the Full
stack. This is enabled through the addition of the `krb5-user` package in our
stack definition. Unfortunately, the Full stack also includes a number of other
packages that many application developers would like to avoid installing.

Creating a new Kerberos buildpack will allow these developers to make a more
focused addition to their application image be ensuring that only those
packages relating to Kerberos are installed. It will also allow the project to
support Kerberos on top of stacks that are not the Full stack without needing
to also include that package in these other stack definitions.

## Detailed Explanation

A new repository will be created at `paketo-buildpacks/kerberos`. This repo
will house a buildpack that has the singular purpose of installing the Kerberos
libraries and executables into a layer made available to other buildpacks or at
runtime. The buildpack will include Kerberos as a precompiled package that can
be dropped into a layer with support for Jammy only. The buildpack will follow
the existing provide/requires conventions, exposing a dependency called
`kerberos`.

Note on Bionic: Lacking any direct feedback about a desired for this support on
Bionic, we will explicitly ignore Bionic support for the initial implementation
of this buildpack.

## Rationale and Alternatives

An alternative would be to add the `krb5-user` package to the Base stack
images. Avoiding this would be preferrable as we should try not to increase the
scope or vectors of attack for our most commonly used stack image.

Another alternative would be to use the new Stack Extensions feature of the CNB
spec to install the `krb5-user` package dynamically. Unfortunately, the
implementation that has shipped at this point is insufficient to enable this
outcome without significant maintenance burden on stack maintainers.
Specifically, stack run images cannot be modified, only replaced entirely. This
would mean that the stacks team would be required to produce images that are
simply `<stack-variant> + krb5-user` for every stack we support going into the
future. The CNB team is interested in solving the run image extension problem,
but the timeline for a solution and its implementation is very vague at this
point.

## Implementation

The implementation will use all of the new dependency management infrastructure
and so be contained to this one repository. The dependency will need to be
compiled against a Jammy stack and hosted by ourselves as no precompiled
distribution has been found.

## Prior Art

The most immediately similar example of this kind of library-installing
buildpack is the ICU buildpack that is used within the .NET Core language
family.

## Unresolved Questions and Bikeshedding

* Should we explore using stack extensions to implement this?
* What team should own this buildpack?
