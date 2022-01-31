# Support "zero-configuration" build processes

## Summary
The NGINX and HTTPD buildpacks within the Web Servers language-family should
provide a "zero-configuration" option whereby they generate a very simple
configuration so that the buildpack user does not need to.

## Motivation

Many users have very simple static file deployments. In these cases, requiring
them to include a bunch of NGINX or HTTPD configuration boilerplate alongside
their static files can be a burden. Instead, we should allow them to indicate
that they have some files to serve in the simplest possible way.

## Detailed Explanation

The NGINX and HTTPS buildpacks will implement a common interface through an
environment variable that will allow them to detect and build when a
configuration file is not present in the application workspace. Specifically,
when the `BP_WEB_SERVER` environment variable is set to either `nginx` or
`httpd` then the respective buildpack will detect and ensure that a simple
configuration file is included in the built image such that it can serve very
basic static file applications.

The configuration files will make assumptions about certain options, like the
location of the files to be served. However, in some cases, the buildpacks
could choose to allow buildpack users to configure some commonly-specified
options (e.g. `BP_WEB_SERVER_ROOT=/workspace/my-build-directory`). This RFC
will not enumerate these options.

## Rationale and Alternatives

### Why not Staticfile?
This proposal sounds a lot like what the existing Staticfile buildpack is
already doing, allowing users to indicate that they would like a simple
configuration for the web server of their choice generated at build time to
serve their static files.

In the simplest cases, this is as easy as including the following
`buildpack.yml` file in their codebase:

```yaml
staticfile:
  nginx: {}
```

However, many users find themselves needing more than just the simplest
configuration. They want support for SSI and HSTS, Basic Auth, and enforcement
of HTTPS connections. This has created a slippery slope in the Staticfile
buildpack where it is slowly recreating each of the configuration options
already available in a proper web server configuration file with a more limited
API. In most cases, users working with the Staticfile buildpack would likely be
better off using the NGINX or HTTPD buildpacks directly. They'd have better
control over their deployment configuration and the complete set of
configuration options provided by that server.

This also doesn't take into account that the current implementation is
completely built upon a concept that we've been trying to remove from all of
the buildpacks in Paketo, the `buildpack.yml` file. We could convert the
buildpack to read its configuration from a `Staticfile` file like what is done
in the Cloud Foundry buildpack, but this doesn't do anything to resolve the
"slippery slope" concern.

## Implementation

Each of the `nginx` and `httpd` buildpacks should introduce support for the
`BP_WEB_SERVER` environment variable. The addition of this support will then
negate the majority of the need for supporting the `staticfile` buildpack
within the Web Servers language-family.

## Prior Art

The `staticfile` buildpack shows what a very basic configuration for NGINX
might look like. This would be the `nginx.conf` file that is generated when
given the simplest Staticfile configuration outlined earlier in this RFC.
