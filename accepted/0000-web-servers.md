# Web Servers Buildpack Subteam

## Summary

A new "Web Servers" buildpack subteam should be established to maintain and
distribute the existing set of related buildpacks that interact in the web
server space.

## Motivation

The existing NGINX, Apache HTTP Server, and Staticfile buildpacks have a common
set of concerns within the web server space. However, the buildpacks are
currently maintained either through tangentially-related subteams (PHP) or not
at all through a subteam (Staticfile). Giving these buildpacks a common subteam
that can hear community concerns and maintain the buildpacks more effectively
while reducing the scope of responsibilities for the PHP subteam would be a
positive benefit for the core development team and the community.

## Detailed Explanation

The Web Server subteam will take over maintenance of the existing
[NGINX](https://github.com/paketo-buildpacks/nginx) and [Apache HTTP
Server](https://github.com/paketo-buildpacks/httpd) buildpacks, as well as the
[Staticfile](https://github.com/paketo-community/staticfile) buildpack.

Additionally, this subteam will create a new language-family buildpack that
will package these buildpacks together in collaboration. This buildpack should
start out as a new addition to the [Paketo Community
organization](https://github.com/paketo-community).

## Rationale and Alternatives

We could choose to maintain the status quo.

## Implementation

New maintainers should be elected for this subteam. These maintainers can then
elect contributors to help support the responsibilities of the subteam.

A new GitHub team for Web Servers should be established. Within that team, both
maintainers and contributors teams should be created with those chosen
individuals included in their corresponding team. This GitHub team will also
need to be created in the Paketo Community organization as the repositories
this subteam maintains will span both organizations.

The maintainer/contibutor ownerships for the NGINX, Apache HTTP Server, and
Staticfile buildpack repositories should be transfered to this subteam.
Additionally, the CODEOWNERS for those repositories should be transferred.

A new buildpack repository should be created in the Paketo Community
organization to the Web Server language-family buildpack. This buildpack should
include a `buildpack.toml` that declares an order grouping like the following:

```toml
[[order]]

  [[order.group]]
    id = "paketo-buildpacks/nginx"
    version = "1.2.3"

  [[order.group]]
    id = "paketo-community/staticfile"
    version = "1.2.3"

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/nginx"
    version = "1.2.3"

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/httpd"
    version = "1.2.3"
```

The language-family buildpack should produce releases and make itself available
on the `gcr.io/paketo-community` image registry.

## Unresolved Questions and Bikeshedding

- How should the maintainers be elected?

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
