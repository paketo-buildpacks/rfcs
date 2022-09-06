# Web Server Buildpack Re-architecture

## Summary

The Nginx and HTTPD buildpacks will be broken into three buildpacks each to
allow for features to decrease the complexity of each of the component
buildpacks and to allow for easier use of the underlying dependencies.

## Motivation

Currently Nginx and HTTPD behave as monolithic buildpacks, installing a
dependency, running configuration, and writing a start command. This is
antithetical to the Paketo buildpack philosophy as it means that the buildpacks
are not modular and it is hard to use components of the buildpack easily.

For example, the PHP buildpacks have both the Nginx and HTTP as a dependency
because both can be used and web servers for PHP applications. However, the PHP
buildpacks only really need the web server dependencies to be installed and
then custom PHP specific configurtaion will be written to make the selected web
server work optimally. This means that in order for the current buildpack
configuration to work we must write the current Nginx and HTTPD buildpacks in
such a way that their configuration can be overwritten in a later buildpack.
This means that any an all new features must take into acount their interaction
with both the Web Servers language domain as well as the PHP language domain.
This development and interaction would be greatly simplified if the PHP
buildpacks could just require the dependency that they need without any of the
attached configuration.

## Implementation

Split each of these buildpacks in three seperate buildpacks

### {web-server}
This buildpack will be responsible for installing a distribution of the web
server in question. By separating this buildpack out we will make the
dependency ingestible by more buildpack groups and make it easier to write new
functionality for the web server by adding a custom or new buildpack.

### {web-server}-zero-configuration
This buildpack will be responsible for setting configuration that is needed by
the zero configuration feature. By separating this buildpack out it should make
it easier to maintain and potentially add more zero configuration features in
the future.

### {web-server}-start
This buildpack will be responsible for writing the start command and adding in
exec.d processes that might be necessary. By separating this out we can be more
selective about which phase we require the web server and it will be easier to
make targeted changes to either the start commands or the exec.d processes.

### Web Servers Order Group
The following is what the order group in the Web Servers buildpack would look
like:

```toml
[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/node-engine"

  [[order.group]]
    id = "paketo-buildpacks/yarn"

  [[order.group]]
    id = "paketo-buildpacks/yarn-install"

  [[order.group]]
    id = "paketo-buildpacks/node-run-script"

  [[order.group]]
    id = "paketo-buildpacks/nginx-dist"

  [[order.group]]
    id = "paketo-buildpacks/nginx-zero-configuration"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/nginx-start"

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/node-engine"

  [[order.group]]
    id = "paketo-buildpacks/npm-install"

  [[order.group]]
    id = "paketo-buildpacks/node-run-script"

  [[order.group]]
    id = "paketo-buildpacks/nginx-dist"

  [[order.group]]
    id = "paketo-buildpacks/nginx-zero-configuration"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/nginx-start"

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/node-engine"

  [[order.group]]
    id = "paketo-buildpacks/yarn"

  [[order.group]]
    id = "paketo-buildpacks/yarn-install"

  [[order.group]]
    id = "paketo-buildpacks/node-run-script"

  [[order.group]]
    id = "paketo-buildpacks/httpd-dist"

  [[order.group]]
    id = "paketo-buildpacks/httpd-zero-configuration"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/httpd-start"

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/node-engine"

  [[order.group]]
    id = "paketo-buildpacks/npm-install"

  [[order.group]]
    id = "paketo-buildpacks/node-run-script"

  [[order.group]]
    id = "paketo-buildpacks/httpd-dist"

  [[order.group]]
    id = "paketo-buildpacks/httpd-zero-configuration"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/httpd-start"

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/nginx-dist"

  [[order.group]]
    id = "paketo-buildpacks/nginx-zero-configuration"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/nginx-start"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/httpd-dist"

  [[order.group]]
    id = "paketo-buildpacks/httpd-zero-configuration"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/httpd-start"

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true
```

## Rationale and Alternatives

- Do nothing and ensure that the web server dependencies are ingestible by
  third party buildpacks by ensuring that all web server specific configuration
  is able to be overwritten by later buildpacks that may need to set up
  language family specific configuration.

## Prior Art

- [A Philosophy for Developing Paketo Buildpacks, Part 1](https://blog.paketo.io/posts/buildpack-philosophy-part-1/)
