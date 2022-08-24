# Decide which `web-server` dependencies will be Paketo-hosted

## Proposal

The following dependencies should be kept as Paketo-hosted dependencies:
* [nginx](https://github.com/paketo-buildpacks/nginx/blob/main/buildpack.toml)
* [httpd](https://github.com/paketo-buildpacks/httpd/blob/main/buildpack.toml)

## Rationale

### nginx

Keep this as a Paketo-hosted dependency.

The nginx server has many different features that are not enabled by default in an upstream binary. To enable specific
nginx features, nginx must be compiled from source using its `configure` script with the appropriate options. For example,
to enable debug logging, the `configure` script has to run using the `--with-debug` option. Since the nginx buildpack supports
several non-default features, this RFC does not propose removing nginx as a Paketo-hosted dependency.  All the features that are
currently included in the Paketo nginx dependency can be found [here](https://github.com/cloudfoundry/buildpacks-ci/blob/0feb3c1ffd58d9021f3edf2988833d6265db5a23/tasks/build-binary-new/builder.rb#L320).

Currently nginx uses `dep-server`, `binary-builder`, and `buildpacks-ci` to build, but language family maintainers
will transition this to the new Github Action workflow once that has been approved.

### httpd

Keep this as a Paketo-hosted dependency.

Similar to the nginx server, the httpd server is customizable and several features are not included by default in httpd upstream binaries.
In addition, [Apache's site](https://httpd.apache.org/docs/2.4/install.html#page-header) states that "binary releases are often not up
to date with the latest source releases" and recommends compiling from source. Therefore, this RFC does not propose removing httpd as a
Paketo-hosted dependency.  All the features that are currently included in the Paketo httpd dependency can be found [here](https://github.com/cloudfoundry/binary-builder/blob/543c706d05f0245f476f47c7add22fbb35758761/recipe/httpd_meal.rb#L41).

Currently httpd uses `dep-server`, `binary-builder`, and `buildpacks-ci` to build, but language family maintainers
will transition this to the new Github Action workflow once that has been approved.
