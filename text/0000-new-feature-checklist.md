# New Feature Checklist

## Summary

Layout out a checklist of tasks to ensure the smooth addition of a new feature
into a buildpack.

## Motivation

Currently there is no defined workflow for ensuring the smooth introduction of
features into buildpacks. This means that steps often get overlooked and
forgotten by maintainers. It also means that it is hard for new contributors to
follow a smooth process and for them to understand what is fully required to
introduce a new buildpack feature. Having something like a checklist would
allow maintainers to become more consistent in enforcing a process for rolling
out a new feature and will give new contributors a layout and plan for how they
can go about adding a new feature that will be easily rolled out.

## Implementation

Add a new section to the
[CONTRIBUTING.md](https://github.com/paketo-buildpacks/.github/blob/main/CONTRIBUTING.md)
file. The section should be added after "How do I contribute?".

The contents of the new section should be as follows:
```markdown
## How do new features get added?

Small features can be added directly to buildpacks, simply open an enhancement issue.

Larger features, more complicated features, and features that cross multiple buildpacks have a more defined process. If you are looking to propose and/or contribute a larger feature, please follow the checklist below.

- [ ] (If necessary) Open an RFC in the [RFCs repository](https://github.com/paketo-buildpacks/rfcs) to discuss the addition of the feature
- [ ] (Optional) Open tracking issue in relevant buildpack repository
- [ ] Open PR adding new feature to codebase
    - [ ] (If necessary) Add integration test that exercises the new feature
    - [ ] (If necessary) Update the README of the buildpack
- [ ] Secure a release of the buildpack
- [ ] (If necessary) Secure a release any and all family buildpacks that contain the new implementation buildpack
- [ ] (Optional) Secure release of builders that contain the new buildpack
- [ ] Update [website documentation](https://github.com/paketo-buildpacks/paketo-website) to expose the feature in the documentation
- [ ] (If necessary) Update the samples in the [samples repository](https://github.com/paketo-buildpacks/samples) to expose the feature
```
