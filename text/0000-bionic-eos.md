# End of Life for Ubuntu 18.04 (Bionic)

## Summary

On May 31st 2023, Ubuntu 18.04 (Bionic Beaver) will go out of support for OSS customers ([source](https://ubuntu.com/blog/18-04-end-of-standard-support)). At this time, Paketo will stop supporting this stack.

We will stop building new stacks, builders, and Bionic-specific dependencies, but we will not remove any of the existing artifacts (images, dependencies, etc). This will ensure backwards-compatibility where needed.

## Motivation

There will be no more updates to Ubuntu Bionic after the End of Support, so the stacks will become vulnerable as CVEs are discovered and not fixed upstream. Similarly, buildpack dependencies (like go, cpython, etc) may not fix vulnerabilities if they are only exploitable on Ubuntu Bionic.

It is a better user experience to explictly remove support for these stacks rather than continue to support them knowing that they are potentially vulnerable. It will also reduce complexity in CI and reduce the number of dependencies in a buildpack's `buildpack.toml` file.

## Detailed Explanation

This end of support will entail the following:

### Stacks
1. Disable the CI that builds the Bionic stacks.
1. Archive the GitHub repositories for the Bionic stacks (with a note in the README indicating end of support, and with all other content preserved for posterity/discoverability).

### Builders
1. Disable the CI that builds the Bionic builders.
1. Archive the GitHub repositories for the Bionic builders (with a note in the README indicating end of support, and with all other content preserved for posterity/discoverability).

### Buildpacks
1. Stop compiling dependencies for Bionic in buildpacks that currently support them.
1. Remove Bionic-specific dependencies from the `buildpack.toml` metadata.

### Documentation
1. Ensure all documentation (and samples) replaces all references to Bionic with Jammy (22.04).
1. Write a blog post to announce this end of support.

We will leave it up to the relevant maintainers (stacks, builders, language-families, content) to decide on a suitable timeline for completion of the above items. For example, language family maintainers may wish to continue building and including Bionic dependencies even after the Bionic stacks/builders are removed if they believe it provides value to their consumers. This RFC will not be fully implemented until all the above points are addressed, though.

## Rationale and Alternatives

1. Continue to run the stacks/builders CI. This is pointless because there will not be new updates so the CI will be wasting resources checking for updates.
1. Do not mark the stacks/builders GitHub repositories as end-of-support. This is a poor user experience given the stacks/builders are not being updated. It is misleading to potential consumers.
1. Continue compiling and distributing buildpack dependencies for Bionic. This is a waste of resources if the buildpack is not updated in the builders and users do not use the stack because it is potentially vulnerable.
1. Continue to include the dependencies in `buildpack.toml`. This is confusing to buildpack authors and potentially misleading if they aren't being updated/compiled upstream.
1. Leave documentation/samples/blog as-is. This is a poor user experience for consumers as they will see references to Bionic stacks even though they are not supported

## Implementation

* Update stack/builder READMEs with end-of-support notices and archive the repositories (this will also disable the GitHub actions that build the stacks/builders)
* Remove Bionic dependency compilation code and GitHub actions for buildpacks that compile their dependencies
* Remove Bionic dependencies from `buildpack.toml`
* Update website/samples/blog to remove references to Bionic stacks, builders, and dependencies

## Prior Art

We haven't deprecated stacks in Paketo before, nor done any large-scale, cross-cutting, deprecation like this before.

## Unresolved Questions and Bikeshedding

* the floor is open to any questions from the community
