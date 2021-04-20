# Environment Variable Configuration Of Buildpack
Supersedes [RFC #0003](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0003-replace-buildpack-yml.md)

## Summary

Environment variables passed in at build time via the command line or
`project.toml` should be the main means for user configuration of a buildpack's
detect/build processes.

## Motivation

There are often situations in which users need to configure or customize
aspects about their applications build process (i.e. build flags in Go, project
path in .Net, etc). There are also some buildpacks specific settings
(dependency versions) that the user might also want/need to control.

## Detailed Explanation

In [RFC #0003](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0003-replace-buildpack-yml.md)
it was proposed to use the Build Plan buildpack to pass all configuration as
part of the `build plan`. This proved to have unforeseen negative consequences,
chief among them there was no way to pass configuration data to the detect
process of a buildpack because the information embedded in the `build plan`
would only become available to the buildpack in the `buildpack plan` during
build. It has since been decided in a number of the buildpack families to use
environment variables instead of the Build Plan buildpack.

This RFC is meant to catalog this distributed design decision. This RFC is also
meant to be a formal superseding [RFC #0003](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0003-replace-buildpack-yml.md)
to ensure the chain of decision making remains somewhat intact.
