# Buildpack.yml to Environment Variables

## Proposal

Migrate to using environment variables to do all buildpack configuration and
get rid of `buildpack.yml`.

## Motivation

There are several reasons for making this switch.
1. There is already an [existing RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0026-environment-variable-configuration-of-buildpacks.md)
   that proposes moving away from `buildpack.yml` as a configuration tool.
1. Environment variables appears to be the standard for configuration in other
   buildpack ecosystems such as Google Buildpacks and Heroku as well as the
   Paketo Java buildpacks. Making this change will align the buildpack with the
   rest of the buildpack ecosystem.
1. There is native support to pass environment variables to the buildpack
   either on a per run basis or by configuration that can be checked into
   source control, in the form of `project.toml`.

## Implementation

The proposed environment variables for PHP Web are as follows:

### `BP_PHP_VERSION`
```shell
$BP_PHP_VERSION="7.4.x"
```

This will replace the following structure in `buildpack.yml`:
```yaml
php:
 version: 7.4.x
```

### `BP_PHP_SERVER`
```shell
$BP_PHP_SERVER="php-server"
```

This will replace the following structure in `buildpack.yml`:
```yaml
php:
 webserver: php-server
```
### `BP_PHP_WEB_DIR`
```shell
$BP_PHP_WEB_DIR="htdocs"
```

This will replace the following structure in `buildpack.yml`:
```yaml
php:
 webdirectory: htdocs
```

### `BP_PHP_LIB_DIR`
```shell
$BP_PHP_LIB_DIR="lib"
```

This will replace the following structure in `buildpack.yml`:
```yaml
php:
 libdirectory: lib
```

### `BP_PHP_SERVER_ADMIN`
```shell
$BP_PHP_SERVER_ADMIN="admin@localhost"
```

This will replace the following structure in `buildpack.yml`:
```yaml
php:
 serveradmin: admin@localhost
```

### `BP_PHP_ENABLE_HTTPS_REDIRECT`
```shell
$BP_PHP_ENABLE_HTTPS_REDIRECT="true"
```

This will replace the following structure in `buildpack.yml`:
```yaml
php:
 enable_https_redirect: true
```

### Configuration Removal
The following structure in `buildpack.yml` will not be receiving an environment
variable configuration option:
```yaml
php:
 script:
```
This structure was effectively taking the part and behavior of [Paketo Procfile
buildpack](https://github.com/paketo-buildpacks/procfile) by allowing users to
provide a start command in `buildpack.yml`. However, as part of the [PHP Rewrite RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/php/0001-restructure.md)
the Procfile buildpack will be added to all order groupings. Because of this
addition I am proposing the removal of this configuration option in the
environment variables in favor of encouraging users to use a Procfile if they
need to set a custom start script.

```yaml
php:
 redis:
   session_store_service_name: redis-sessions
 memcached:
   session_store_service_name: memcached-sessions
```
Both of these configuration options are going to be replaced with standardized
service binding types. The types will be `php-redis-session` and
`php-memcached-session` respectively.

---
The proposed environment variables for Composer are as follows:

### `BP_COMPOSER_VERSION`
```shell
$BP_COMPOSER_VERSION="1.10.x"
```

This will replace the following structure in `buildpack.yml`:
```yaml
composer:
  version: 1.10.x
```

### `BP_COMPOSER_INSTALL_OPTIONS`
```shell
$BP_COMPOSER_INSTALL_OPTIONS="--no-dev --prefer-install=auto"
```

Note: This will be parsed using this [shellwords library](https://github.com/mattn/go-shellwords).

This will replace the following structure in `buildpack.yml`:
```yaml
composer:
  install_options: ["--no-dev", "--prefer-install=auto"]
```

### `BP_COMPOSER_INSTALL_GLOBAL`
```shell
BP_COMPOSER_INSTALL_GLOBAL="friendsofphp/php-cs-fixer squizlabs/php_codesniffer=*"
```

This will replace the following structure in `buildpack.yml`:
```yaml
composer:
  install_global:
    - friendsofphp/php-cs-fixer
    - squizlabs/php_codesniffer=*
```

This will also replace the prior env variable `BP_COMPOSER_GLOBAL_INSTALL_OPTIONS`.
The purpose of `BP_COMPOSER_INSTALL_GLOBAL` is to specify packages for
global installation, not to provide options.

### Configuration Removal
The following structure in `buildpack.yml` will not be receiving a buildpack
specific environment variable configuration option:
```yaml
composer:
  json_path: composer
```
This structure is effectively performing the function of the
[`$COMPOSER`](https://getcomposer.org/doc/03-cli.md#composer) environment
variable that is natively supported by `composer`. Therefore the structure is
being removed in favor of the native solution.

The following structure in `buildpack.yml` will not be receiving a buildpack
specific environment variable configuration option:
```yaml
composer:
  vendor_directory: vendor
```
If the user would like to set a custom `composer` vendoring location they can
use the
[`$COMPOSER_VENDOR_DIR`](https://getcomposer.org/doc/03-cli.md#composer-vendor-dir)
environment variable native to `composer`.
Note:
The value of `$COMPOSER_VENDOR_DIR` will be modified by the buildpack in order
to set up efficient caching; these changes will be logged for the user to
observe and will also be documented.

The environment variable `COMPOSER_GITHUB_OAUTH_TOKEN` will not receive a buildpack
specific environment variable configuration option, since it performs the same use case
as the [`$COMPOSER_AUTH`](https://getcomposer.org/doc/03-cli.md#composer-auth) environment variable
that is natively supported by `composer`. Therefore, the environment variable will be removed
in favor of the native solution.

---

### Deprecation Strategy

A deprecation warning will be added warning users that support for
`buildpack.yml` will be removed in the next major version in favor of
environment variable configuration.A deprecation warning will be added warning
users that support for `buildpack.yml` will be removed in the next major
version in favor of environment variable configuration. Once the major bump
does occur, the buildpack should fail applications that still have a
`buildpack.yml` until the next minor release to ensure that people are
migrating to the environment variable configuration.

## Source Material
* [Google buildpack configuration](https://github.com/GoogleCloudPlatform/buildpacks#language-idiomatic-configuration-options)
* [Paketo Java configuration](https://paketo.io/docs/buildpacks/language-family-buildpacks/java)
* [Heroku configuration](https://github.com/heroku/java-buildpack#customizing)
* [PHP Web `buildpack.yml` Configurations](https://github.com/paketo-buildpacks/php-web#buildpackyml-configurations)
* [PHP Composer `buildpack.yml` Configurations](https://github.com/paketo-buildpacks/php-composer#buildpackyml-configurations)

## Unresolved Questions and Bikeshedding

- Should we remove the `BP_PHP_SERVER` configuration in favor a multi-buildpack
  build as outlined in [this comment thread](https://github.com/paketo-buildpacks/php/issues/472)
  on the issue for this RFC.

## Edits
EDIT 04/05/2022: Replace `BP_COMPOSER_GLOBAL_INSTALL_OPTIONS` with `BP_COMPOSER_INSTALL_GLOBAL`.
Specify that configuration option `COMPOSER_GITHUB_OAUTH_TOKEN` will be removed.