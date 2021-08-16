# Separate Buildpackless Builder Repos

## Proposal

In [RFC 30 - Buildpackless
Builders](https://github.com/paketo-buildpacks/rfcs/blob/022f8e7fdc193e6b81aa1d3814ea0e00585d3ba7/text/0030-buildpackless-builders.md),
Paketo agreed to begin distributing buildpackless versions of its builders. In
the RFC's implementation section, it was stated that these buildpackless
builders should be checked into the same repos as their standard counterparts.
The process of implementing this approach has revealed some complexity that
increases maintenance burden and difficulty. This RFC proposes an amendment to
RFC 30: the buildpackless builders should be checked into their own repos.

## Motivation

Initially, we thought that keeping the buildpackless builders in the same repos
as their standard counterparts would reduce maintenance overhead (mostly
because no new repos would need to be maintained). However, after having
implemented the proposed automation for the Paketo [Full
Builder](https://github.com/paketo-buildpacks/full-builder), the pain points of
rolling out the implementation became more clear.

The standard builders' automations (GHA workflows, test-running scripts, etc.)
are maintained as part of the shared
[github-config](https://github.com/paketo-buildpacks/github-config) repository.
Periodically, automation opens a pull request against each builder repo to
resolve differences between the `main` branch of the builder repo and the
centralized set of automations.

In the proposed orphaned-branch implementation of the buildpackless builders,
there are two branches that must be periodically reconciled with a central
source of truth: `main` and `buildpackless`. These need some – but not all – of
the same automations and configuration files to be present and up to date. For
instance, both `main` and `buildpackless` should have identical copies of
[`tools.json`](https://github.com/paketo-buildpacks/full-builder/blob/2f858829f362f59ce4f5c401f3c590c43f0d6f10/scripts/.util/tools.json).
But `main` and `buildpackless` need different versions of `create-release.yml`
workflows. (Compare
[`main`](https://github.com/paketo-buildpacks/full-builder/blob/2f858829f362f59ce4f5c401f3c590c43f0d6f10/.github/workflows/create-release.yml)
vs.
[`buildpackless`](https://github.com/paketo-buildpacks/full-builder/blob/069880204e2b3554a8991976979acbed0862e81f/.github/workflows/create-release-buildpackless.yml).)

So, the single-repo implementation introduces complexities like:

- How do we ensure that `main` and `buildpackless` don't diverge from their
  sources of truth?
- How do we ensure that the sources of truth are consistent with each other for
  the workflows that should be common between them?

The answer to those questions is "more automation," which we could implement.
This would involve many more cron jobs and some more nested directories inside
of the `github-config` repo. 

 But I argue that it would be simpler to check each buildpackless builder into
 its own repo. These repos could use all of the same workflows and scripts
 already defined in the `github-config` repo for builders with limited
 modification required.
