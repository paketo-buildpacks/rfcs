# Rails Asset Pipeline Support

## Proposal

Include a Rails assets buildpack in the Ruby buildpack family. The buildpack
will be charged with precompiling assets so that they can be accessed in a
production deployment. The buildpack will be included in each of the
"webserver" buildpack groups, but not the Rake group. To support the buildpack
build process, the `node-engine` buildpack will also be included in any group
that includes the new buildpack.

## Motivation

[Rails](https://rubyonrails.org/) is a popular web framework used in the Ruby
community. In recent versions of Rails, Javascript, CSS, and other front-end
assets are managed in a build system called the [Asset
Pipeline](https://guides.rubyonrails.org/asset_pipeline.html).

Rails developers that use the Asset Pipeline will expect that their assets are
precompiled and made available in the built image. This means that the Ruby
buildpack groups should include a buildpack that executes this process to
precompile assets when it is needed.

## Implementation

A new `rails-assets` buildpack will be developed to detect that the Rails Asset
Pipeline is present, and then precompile those assets so that they can be
included in the built image.

### Detection Criteria

The buildpack will detect if the `Gemfile` contains the `rails` gem and the
`app/assets` directory is present. According to the
[documentation](https://guides.rubyonrails.org/asset_pipeline.html#how-to-use-the-asset-pipeline),
the `app/assets` directory is the location that a Rails application will expect
to find assets that need to be compiled before a production deployment.

If the buildpack detects, then it will need to require `node` since a Node.js
runtime is required to execute the asset precompilation process.

### Build Process

The build process of the buildpack will execute a precompilation process that
generates a set of assets to be served in a production deployment.  The
[documentation](https://guides.rubyonrails.org/asset_pipeline.html#precompiling-assets)
outlines that assets can be precompiled by executing `bundle exec rails
assets:precompile`.

This choice means that we will only be supporting Rails >= 5.0. Rails versions
prior to 5.0 used a Rake task to precompile assets with a command like `bundle
exec rake assets:precompile`. It is reasonable to only support these more
recent versions as Rails versions prior to 5.0 are [no longer
supported](https://guides.rubyonrails.org/maintenance_policy.html) by the
project.

### Ruby Buildpack Order Grouping

The `rails-assets` buildpack will be included in each of the "webserver"
buildpack groups (`puma`, `thin`, `unicorn`, `passenger` and `rackup`). In each
case, the buildpack will be marked as optional. The `rails-assets` buildpack
**will not** be included in the `rake` order grouping. Immediately before the
`rails-assets` buildpack, the `node-engine` buildpack will also be included as
optional.

Given these changes, the updated order grouping for the Ruby buildpack will
look like the following:

```toml
[[order]]

  [[order.group]]
    id = "paketo-buildpacks/mri"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundler"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundle-install"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/node-engine"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/rails-assets"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/puma"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "<version>"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/mri"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundler"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundle-install"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/node-engine"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/rails-assets"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/thin"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "<version>"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/mri"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundler"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundle-install"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/node-engine"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/rails-assets"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/unicorn"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "<version>"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/mri"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundler"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundle-install"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/node-engine"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/rails-assets"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/passenger"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "<version>"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/mri"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundler"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundle-install"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/node-engine"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/rails-assets"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/rackup"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "<version>"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/mri"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/bundler"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/bundle-install"
    version = "<version>"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/rake"
    version = "<version>"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "<version>"
    optional = true
```
