# Dependency Management Phase 3: Dep-Server Simplification RFC

## Proposal

This RFC proposes that the
[dep-server](https://github.com/paketo-buildpacks/dep-server) application and
associated code are simplified and moved into maintenance mode as a part of
efforts to improve dependency management in the project. With changes outlined
in [Phase
1](https://github.com/paketo-buildpacks/rfcs/blob/main/text/dependencies/rfcs/0004-dependency-management-phase-one.md)
and [Phase
2](https://github.com/paketo-buildpacks/rfcs/blob/main/text/dependencies/rfcs/0005-dependency-management-phase-two.md)
the dep-server itself will no longer be the source of dependency updates, and
will be maintained to continue serving existing legacy dependencies only.  It
will also become a repository to host cross-dependency libraries.


## Motivation and Background

Per top-level [RFC 0000:
Overview](https://github.com/paketo-buildpacks/rfcs/blob/main/text/dependencies/rfcs/0003-dependency-management-overview.md),
the third phase of the dependency management improvement process is to simplify
the dep-server and the related codebase. Simplifying the code that lives in the
repository will allow for easier maintenance and reuse by others.

The current dep-server app is quite opaque, it runs in Google App Engine, but
serves dependencies and metadata stored in AWS S3 buckets through a complicated
set of AWS Route 53 routing to `*.deps.paketo.io` domains that are
registered in GCP. A goal of this work is to unify the dep-server to a single
IAAS, GCP

With changes to the dependency management process outlined in the Phase 2 RFC,
the dep-server will no longer be needed to update dependencies in our
buildpacks.

## Detailed Explanation

### Maintenance Mode
Following the implementation of Phase 1 and 2, only dependencies that have been
compiled will be uploaded to indiviual dependency-specific GCP buckets under a
Paketo Buildpacks project. However, this will be managed by Github actions that
run in the buildpack, and the dep-server will not have any part in this.

The dep-server will only be hosting legacy dependency versions in their current
locations so that old buildpack versions will continue to work. Eventually,
these dependencies will be removed when the images they are associated with are
removed per the [Image Retention Policy
RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0046-image-retention-policy.md).

### Worklow Removal

### Migration
After Phase 1 and Phase 2 are implemented for a dependency successfully, the
dependency management-related code and workflows in the dep-server can be
removed. Before then, the dep-server will still be used for dependency updates,
as the switch-over process will take time.

In it's final state, the dep-server repository will primarily contain code,
tests, and workflows related to standing up the application to host old
dependencies. Additionally, the repository will hold some dependency helper
code, such as code to get dependency licenses and package URLs, and other
abstractions from dependency management code.

## Rationale and Alternatives

The obvious alternative is to keep using the dep-server as the main arbiter of
dependency management. However, this alternative directly contradicts the
rationale for more or less the entirety of Phase 1, 2, and 3 to simplify our
process and would incur more tech debt in the project to make it work for other
use cases. It's not clear what advantages this would provide, except
potentially introducing less change to the project.

## Unresolved Questions and Bikeshedding (Optional)
- Should we be specific about legacy dependency removal timelines here, or outline this
  in a future RFC?
