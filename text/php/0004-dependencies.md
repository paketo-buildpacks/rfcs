# Decide which PHP dependencies will be Paketo-hosted

## Proposal

Currently two PHP buildpacks have Paketo-hosted dependencies.

| Buildpack                                                                          | Action |
|------------------------------------------------------------------------------------|--------|
| [php-dist](https://github.com/paketo-buildpacks/php-dist/blob/main/buildpack.toml) | Keep   |
| [composer](https://github.com/paketo-buildpacks/composer/blob/main/buildpack.toml) | Remove |

## Rationale

### PHP-Dist

Keep this as a Paketo-hosted dependency.

Currently this uses `dep-server`, `binary-builder`, and `buildpacks-ci` to build.
Buildpack maintainers will move this process to the new dependency workflow.

### Composer

The Composer dependency is currently (as of [2c39d25a](https://github.com/paketo-buildpacks/composer/commit/2c39d25a22f6403a9f77854c9b9247611e168049))
exactly the same as the upstream.
Note that `sha256` and `source_sha256` have been identical for the lifetime of this buildpack.