# Migrating buildpack.yml to Environment Variables for PHP Buildpacks

## Proposal

The RFC proposes a list of environment variables that can be used to set some
configurations for PHP buildpacks.

## Motivation

1. Align buildplan philosophy with our other buildpacks. We are moving away from
   configuring settings via a buildpack.yml to using environment variables
   across all Paketo buildpacks.

1. Per [PHP RFC 0001](https://github.com/paketo-buildpacks/rfcs/blob/main/text/php/0001-restructure.md),
   we are restructuring the PHP language family of buildpacks to make them more modular,
   up-to-date, and as a result, maintainable. Implementing the use of environment variables
   is one of the first steps in this process[<sup>1</sup>](#note-1).

## Configurable Settings

Currently, the `buildpack.yml` file is used to specify:
* PHP versions,
* a user's choice of web-server,
* an alternative web app code directory to htdocs,
* alternative library code directory to lib,
* scripts,
* server admin,
* redis session store service,
* memcache session store service, and
* configuring composer

The new method for specify these settings is to set the following environment variables.

## Environment Variables

For `php-dist` and `php-web` settings:

#### BP_PHP_VERSION
```shell
$BP_PHP_VERSION="7.4.x"
```
This will replace the following structure in `buildpack.yml`
```yaml
php:
  version: 7.4.x
```

#### BP_PHP_WEBDIRECTORY
```shell
$BP_PHP_WEBDIRECTORY="htdocs"
```
This will replace the following structure in `buildpack.yml`
```yaml
php:
  webdirectory: htdocs
```

#### BP_PHP_LIBDIRECTORY
```shell
$BP_PHP_LIBDIRECTORY="lib"
```
This will replace the following structure in `buildpack.yml`
```yaml
php:
  libdirectory: lib
```

#### BP_PHP_SERVERADMIN
```shell
$BP_PHP_SERVERADMIN="admin@localhost"
```
This will replace the following structure in `buildpack.yml`
```yaml
php:
  serveradmin: admin@localhost
```

#### BP_PHP_REDIS_SESSION_STORE_SERVICE_NAME
```shell
$BP_PHP_REDIS_SESSION_STORE_SERVICE_NAME="redis-sessions"
```
This will replace the following structure in `buildpack.yml`
```yaml
php:
  redis:
    session_store_service_name: redis-sessions
```

#### BP_PHP_MEMCACHED_SESSION_STORE_SERVICE_NAME
```shell
$BP_PHP_MEMCACHED_SESSION_STORE_SERVICE_NAME="memcached-sessions"
```
This will replace the following structure in `buildpack.yml`
```yaml
php:
  memcached:
    session_store_service_name: memcached-sessions
```

For `php-composer` settings:

#### BP_PHP_COMPOSER_VERSION
```shell
$BP_PHP_COMPOSER_VERSION="1.10.x"
```
This will replace the following structure in `buildpack.yml`
```yaml
composer:
  version: "1.10.x"
```

#### BP_PHP_COMPOSER_INSTALL_OPTIONS
```shell
$BP_PHP_COMPOSER_INSTALL_OPTIONS="[--no-dev]"
```
This will replace the following structure in `buildpack.yml`
```yaml
composer:
  install_options: ["--no-dev"]
```

#### BP_PHP_COMPOSER_VENDOR_DIRECTORY
```shell
$BP_PHP_COMPOSER_VENDOR_DIRECTORY="vendor"
```
This will replace the following structure in `buildpack.yml`
```yaml
composer:
  vendor_directory: vendor
```

#### BP_PHP_COMPOSER_JSON_PATH
```shell
$BP_PHP_COMPOSER_JSON_PATH="composer"
```
This will replace the following structure in `buildpack.yml`
```yaml
composer:
  json_path: composer
```

#### BP_PHP_COMPOSER_INSTALL_GLOBAL
```shell
$BP_PHP_COMPOSER_INSTALL_GLOBAL="[list, of install, options]"
```
This will replace the following structure in `buildpack.yml`
```yaml
composer:
  install_global: ["list", "of", "install", "options"]
```

## Settings not supported

The following settings will not be migrated to environment variables for `php-web`:

```yaml
php:
  webserver: php-server
```
There will not be an environment variable that users can set to specify their choice of 
webserver. Instead, we propose that users override the default webserver with their desired
server in the buildplan. The webserver will be determined by buildpack order[<sup>2</sup>](#note-2).

```yaml
php:
  script:
```
There will not be an environment variable that users can set to specify a runnable script or
command. Instead, users can include a Procfile or set a start command when running a container
[<sup>3</sup>](#note-3).

## Unresolved Questions

* Since we want users to set their choice of web server with the buildplan instead of an
  environment variable, we will need to agree on a default php webserver. We should discuss
  this with @paketo-buildpacks/php-maintainers.

* Should the names of some of the environment variables be shortened for ease?

## Reference

<a name="note-1">1</a>. [PHP Rewrite](https://github.com/paketo-buildpacks/rfcs/blob/main/text/php/0001-restructure.md)
<a name="note-2">2</a>. [Webserver setting discussion](https://github.com/paketo-buildpacks/php/issues/472#issuecomment-988226743)
<a name="note-3">3</a>. [Script setting discussion](https://github.com/paketo-buildpacks/php/issues/472#issuecomment-988221827)
