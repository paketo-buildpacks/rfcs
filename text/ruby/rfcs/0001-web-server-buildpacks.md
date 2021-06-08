# Ruby Webserver Support

## Proposal

The Ruby buildpack should support, by default, applications that use a Ruby webserver. Full support in this case will mean detecting a specific webserver is required and ensuring a start command for that server is set, along with requiring any needed dependencies for the launch phase. This last requirement is important as none of the mri, bundler, or bundle-install buildpacks will require their dependencies to be made available during launch. To begin with, we will support 5 ruby servers: thin, unicorn, rackup, puma, and passenger.

## Motivation

One of the primary use-cases for the Ruby buildpack will be to build applications that act as webservers. There are a number of webservers in the Ruby community that are in wide-use. We should enable support for these webservers by default while also allowing developers to override the start command to support their unique use-case.

## Implementation

The 5 webservers will be defined in order groupings that are mutually exclusive to one another as can be seen below:

```toml
[[order]]

  [[order.group]]
    id = "paketo-community/mri"
    version = "0.0.121"

  [[order.group]]
    id = "paketo-community/bundler"
    version = "0.0.107"

  [[order.group]]
    id = "paketo-community/bundle-install"
    version = "0.0.11"

  [[order.group]]
    id = "paketo-community/puma"
    version = "0.0.3"


[[order]]

  [[order.group]]
    id = "paketo-community/mri"
    version = "0.0.121"

  [[order.group]]
    id = "paketo-community/bundler"
    version = "0.0.107"

  [[order.group]]
    id = "paketo-community/bundle-install"
    version = "0.0.11"

  [[order.group]]
    id = "paketo-community/thin"
    version = "0.0.3"

[[order]]

  [[order.group]]
    id = "paketo-community/mri"
    version = "0.0.121"

  [[order.group]]
    id = "paketo-community/bundler"
    version = "0.0.107"

  [[order.group]]
    id = "paketo-community/bundle-install"
    version = "0.0.11"

  [[order.group]]
    id = "paketo-community/unicorn"
    version = "0.0.3"

[[order]]

  [[order.group]]
    id = "paketo-community/mri"
    version = "0.0.121"

  [[order.group]]
    id = "paketo-community/bundler"
    version = "0.0.107"

  [[order.group]]
    id = "paketo-community/bundle-install"
    version = "0.0.11"

  [[order.group]]
    id = "paketo-community/passenger"
    version = "0.0.3"

[[order]]

  [[order.group]]
    id = "paketo-community/mri"
    version = "0.0.121"

  [[order.group]]
    id = "paketo-community/bundler"
    version = "0.0.107"

  [[order.group]]
    id = "paketo-community/bundle-install"
    version = "0.0.11"

  [[order.group]]
    id = "paketo-community/rackup"
    version = "0.0.3"
```

Choosing to make these groups mutually exclusive to one another instead of as a single group with several optional webservers is to ensure that we only detect 1 webserver per build, and that we keep error messages as clear as possible.

Only detecting a single webserver buildpack will ensure that we don't have confusing output, eg. an app that included both `unicorn` and `rack` in its Gemfile would cause both to the detect and both to set a start command, with an unclear output of which wins.

Additionally, if an app were to not cause detection for any webserver with a single group that had optional webserver buildpacks, the error message does not clearly indicate that detection of a webserver is what failed. Instead, the lifecycle prints an error about unrequired dependencies. This type of error message is confusing to the user and should be avoided.

