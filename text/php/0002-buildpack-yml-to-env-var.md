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
### `BP_COMPOSER_VENDOR_DIR`
```shell
$BP_COMPOSER_VENDOR_DIR="vendor"
```

Note: The value of this environment variable will be used to set
[`$COMPOSER_VENDOR_DIR`](https://getcomposer.org/doc/03-cli.md#composer-vendor-dir)
therefore if a user attempts to set this value themselves as well as set the
value of `$BP_COMPOSER_VENDOR_DIR` the value of `$COMPOSER_VENDOR_DIR` will be
overwritten resulting in potentially unexpected behavior.

This will replace the following structure in `buildpack.yml`:
```yaml
composer:
  vendor_directory: vendor
```

### `BP_COMPOSER_HOME`
```shell
$BP_COMPOSER_HOME="composer"
```

Note: The value of this environment variable will be used to set
[`$COMPOSER_HOME`](https://getcomposer.org/doc/03-cli.md#composer-home)
therefore if a user attempts to set this value themselves as well as set the
value of `$BP_COMPOSER_HOME` the value of `$COMPOSER_HOME` will be overwritten
resulting in potentially unexpected behavior.

This will replace the following structure in `buildpack.yml`:
```yaml
composer:
  json_path: composer
```

### `BP_COMPOSER_GLOBAL_INSTALL_OPTIONS`
```shell
$BP_COMPOSER_GLOBAL_INSTALL_OPTIONS="--only-name --type"
```

Note: This will be parsed using this [shellwords library](https://github.com/mattn/go-shellwords).

This will replace the following structure in `buildpack.yml`:
```yaml
composer:
  install_global: ["--only-name", "--type"]
```

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

- Are there any environment variable names that are out of place?
- Should we remove the `BP_PHP_SERVER` configuration in favor a multi-buildpack
  build as outlined in [this comment thread](https://github.com/paketo-buildpacks/php/issues/472)
  on the issue for this RFC.