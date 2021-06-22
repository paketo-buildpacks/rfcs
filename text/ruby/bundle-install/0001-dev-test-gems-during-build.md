# Provide development/test gems during build phase

## Proposal

The buildpack should install and provide gems specified in the `development`
and `test` groups in a layer that is made available to subsequent buildpacks
during the build phase. The buildpack will also continue to exclude these
`development` and `test` gems when providing a layer used for the `launch`
phase.

## Motivation

While we want to ensure we only install "production" dependencies when we build
the application image, there are cases where buildpacks subsequent to the
`bundle-install` buildpack will want to invoke code provided by gems that are
including in the `development` or `test` groups. In its current implementation,
these buildpacks would error as none of those dependencies are provided during
the build phase.

## Implementation

The buildpack will provide 2 different layers depending upon the metadata
indicating what phases the gems will be required in. The implementation will
follow these rules:

1. If the `gems` build plan entry is required during `build`, then the
   buildpack will create a layer with `build` and `cache` flags set to true.
   Into this layer it will install all gems, including those in the
   `development` and `test` groups.

2. If the `gems` build plan entry is required during `launch`, then the
   buildpack will create a layer with the `launch` flag set to true. Into this
   layer it will install only those gems that are not in the `development` or
   `test` groups.

3. If the `gems` build plan entry is required during both `build` and `launch`,
   then the buildpack will perform both of the steps outlined above.

These layers will necessarily contain an overlapping set of gems. This is
tolerable because the layers have different lifecycles, only being exposed to
either the `build` or `launch` phases in a mutually exclusive relationship.

The layers will also leverage build and launch environment variables to
configure the location of the `BUNDLE_USER_CONFIG` environment variable to
ensure the `bundle` CLI uses the correct gem set during each phase.

### Performance Implications

In the worst case, when the `gems` build plan entry is required during both
`build` and `launch`, the buildpack will need to install many of the same gems
twice. To prevent this from being a huge performance penalty, the buildpack
will perform the following steps:

1. Install all gems into the `build` layer.
2. Copy all gems from the `build` layer into the `launch` layer.
3. Execute the `launch` layer install process. This will remove those extra
   `development` and `test` gems as the process will execute `bundle clean`.
