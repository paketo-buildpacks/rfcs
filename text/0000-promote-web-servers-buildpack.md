
# Web Servers Buildpack Promotion

## Summary

A [Web Servers Buildpack](https://github.com/paketo-community/web-servers) exists as a
community created buildpack in the [Paketo Community
Org](https://github.com/paketo-community/web-servers). This RFC proposes the promotion
of the Web Servers Buildpack from a "Community" buildpack to an official Paketo
Buildpack.

## Motivation

The community Web Servers Buildpack has reached an initial feature completion
state and supports a wide range of static applications through HTTPD and NGINX
as well as applications with Javascript frontends.

## Implementation

The following changes will be made:

- [Web Servers Buildpack](https://github.com/paketo-community/web-servers) moved from the
  `paketo-community` to `paketo-buildpacks`and become a part of the Utility
  sub-team.
- Buildpack will have `paketo-buildpacks/web-servers` ID.
- Buildpack will be published to `paketobuildpacks/web-servers`.
- Buildpack will be Paketo Full Builder and the stand-alone entries for NGINX and HTTPD will be removed.
- Versioning of the buildpack will continue as is.
- Sample apps for common Web Servers buildpacks configurations should be added to the
  [Paketo samples repo](https://github.com/paketo-buildpacks/samples)
- Web Sever buildpack documentation should be added to the repos README.
