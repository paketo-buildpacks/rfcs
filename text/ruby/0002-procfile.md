# Procfile Support

## Proposal

The [`Procfile` Buildpack](https://github.com/paketo-buildpacks/procfile/)
should be added as an optional buildpack to the end of all order groups.

## Motivation

The use of a `Procfile` to manage multiple application processes is common in
the Ruby community. Several
[services](https://devcenter.heroku.com/articles/procfile) and
[tools](https://github.com/ddollar/foreman) already have existing support for
this file format. Optionally supporting `Procfile` will allow users to
configure their processes using tools they are already comfortable with.

## Implementation

The `Procfile` buildpack will be added, optionally, as the last buildpack in
each existing order group, as can be seen below:

```toml
[[order]]

  [[order.group]]
    id = "paketo-community/mri"
    version = "0.0.139"

  [[order.group]]
    id = "paketo-community/bundler"
    version = "0.0.126"

  [[order.group]]
    id = "paketo-community/bundle-install"
    version = "0.0.31"

  [[order.group]]
    id = "paketo-community/puma"
    version = "0.0.22"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "1.3.9"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-community/mri"
    version = "0.0.139"

  [[order.group]]
    id = "paketo-community/bundler"
    version = "0.0.126"

  [[order.group]]
    id = "paketo-community/bundle-install"
    version = "0.0.31"

  [[order.group]]
    id = "paketo-community/thin"
    version = "0.0.19"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "1.3.9"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-community/mri"
    version = "0.0.139"

  [[order.group]]
    id = "paketo-community/bundler"
    version = "0.0.126"

  [[order.group]]
    id = "paketo-community/bundle-install"
    version = "0.0.31"

  [[order.group]]
    id = "paketo-community/unicorn"
    version = "0.0.17"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "1.3.9"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-community/mri"
    version = "0.0.139"

  [[order.group]]
    id = "paketo-community/bundler"
    version = "0.0.126"

  [[order.group]]
    id = "paketo-community/bundle-install"
    version = "0.0.31"

  [[order.group]]
    id = "paketo-community/rackup"
    version = "0.0.21"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "1.3.9"
    optional = true
```
