# Modifications to Ruby Buildpacks Dependency Strategy

## Summary

Per the project-wide [dependency-management
RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/dependencies/rfcs/0003-dependency-management-overview.md),
our dependency strategy as it relates to the Paketo Ruby buildpacks is
changing.  This RFC outlines the plan for each of the buildpack-provided
dependencies in the Ruby language family in order to adhere to the new system,
and to move away from using the [Paketo
dep-server](https://github.com/paketo-buildpacks/dep-server).


## Proposal

### Ruby (MRI Buildpack)
Ruby will be kept as a Paketo-hosted dependency. The Ruby project itself has no
pre-compiled binaries available for usage. Compiling  from source is a
recommended way to install it outside of using a specific installler tool or
using a package manager.

The dependency source and new versions can be retrieved from
https://raw.githubusercontent.com/ruby/www.ruby-lang.org/master/_data/releases.yml,
which contains a YAML representation of all Ruby versions, and includes
versions, release dates, the source URI from cache.ruby-lang.org, and SHA256 to
be used for dependency verification. Using this source is a deviation from
where releases are picked up from in the dep-server
(https://cache.ruby-lang.org/pub/ruby/), which had to be parsed with regular
expressions, whereas the new release page can be easily YAML-parsed.

The dependency source code can be built following [Ruby
documentation](https://www.ruby-lang.org/en/documentation/installation/#building-from-source)
or in another fashion maintainers see fit. Regardless, the resulting dependency
should work on both the Bionic and Jammy stack images, as well as be extendable
to work with other stacks in the future.

### Bundler (Bundler Buildpack)

The `bundler` dependency will be kept as a Paketo-hosted dependency, since it
is packaged as a Ruby `gem` file upstream, and needs to undergo some
compilation / processing to be easily consumable in the buildpacks.

New versions of bundler can be retrieved from
https://rubygems.org/api/v1/versions/bundler.json, as well as the associated
SHA256 and release date. The SHA256 can be used for dependency verification.
Once the new versions are discovered, the dependency source can be retrieved
from https://rubygems.org/downloads/bundler-VERSION.gem and used for
compilation.

### Curl (Passenger Buildpack)

The `curl` dependency used in the Passenger buildpack will also be a
Paketo-hosted dependency. Even though there are hosted Linux
distribution-agnostic binaries available at https://curl.se/download.html, they
are provided by third-parties that we don't have enough confidence in to want to
leverage in the project.  Ubuntu, which is a trusted source, also [provides
up-to-date curl binaries](https://packages.ubuntu.com/bionic/curl ), but they
are provided as `.deb` files which are not easily consumed within the
buildpack.

Instead of using the upstream dependency, `curl` will be compiled from source.
New versions will be discovered from
[Github](https://github.com/curl/curl/releases), rather than a Curl CSV
document, which is used [in the
dep-server](https://github.com/paketo-buildpacks/dep-server/blob/f20264702d4010407c54d0c0d2a69186d9d324cf/pkg/dependency/curl.go#L83).
The source used for compilation can be downloaded from
https://curl.se/download/curl-VERSION.tar.gz. The dependency will need to be
compiled in way that will be compatible with the Bionic stack, Jammy stack, and
other future stacks.

Each `curl` dependency has a PGP signature that can be retrieved from
https://curl.se/download/curl-VERSION.tar.gz.asc. In legacy [dep-server
code](https://github.com/paketo-buildpacks/dep-server/blob/f20264702d4010407c54d0c0d2a69186d9d324cf/pkg/dependency/curl.go#L157-L172)
the signature is verified against https://daniel.haxx.se/mykey.asc, the public
key of the author of `curl`. A similar verification step can be performed
during compilation for dependency verification, however the public key should
be downloaded and stored in the buildpack repository for usage for security
purposes.  There are no SHA256 or other checksums published on the website or
in Github releases, so PGP signature verification is the best option. A source
SHA256 should still be manually calculated and added to the metadata for
completeness.


## Unresolved Questions and Bikeshedding
- Is there a better solution for `curl`? Can we somehow leverage `apt` or
  another package manager to get a `curl` installation rather than compiling it
  ourselves?
