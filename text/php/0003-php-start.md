# PHP Start: An Addendum to Restructuring PHP Buildpacks

This RFC serves as an addendum to [PHP RFC
0001](https://github.com/paketo-buildpacks/rfcs/blob/main/text/php/0001-restructure.md)
(Restructuring PHP Buildpacks).

## Proposal

The RFC proposes a change to the plan outlined in the original PHP
restructuring RFC, in order to simplify the PHP HTTPD/Nginx web server
buildpacks, reduce code duplication, and align with the modularity in other
Paketo buildpacks. This will be achieved by delegating all server start
commands to a separate PHP Start buildpack, leaving the PHP HTTPD and PHP Nginx
buildpacks to set up configuration only.


## Motivation

The orignal plan was to create a PHP HTTPD buildpack and a PHP Nginx buildpack, with each
responsible for setting up web server configuration, adding server-specific FPM
configuration, setting the server start command, and setting the FPM start
command. This is suboptimal for a few reasons:

1. Code Duplication - In order to start both the server and FPM, the buildpacks
   would need some fairly complicated logic using Go channels (this is how it's
   accomplished in the existing Paketo PHP Web CNB). This logic would have to
   be duplicated in both the PHP HTTPD and PHP Nginx buildpacks to achieve the
   same behaviour.

2. Lack of Modularity - In the original plan, the buildpacks would be
   responsible for setting up configuration as well as setting start commands.
   This goes against the usual Paketo standard of modular buildpacks that are
   responsible for one main function.


## Implementation

#### Original set up
The two functions from the original proposal we are targeting with this RFC are:
* Build an image to run HTTPD web server with php
* Build an image to run Nginx web server with php

The originally proposed relevant buildpacks were:

* **php-httpd**:
  Sets up HTTPD as the web server to serve PHP applications.
  * provides: none
  * requires: `php` at build; `php`, `php-fpm`, `httpd` at launch

  This buildpack generates `httpd.conf` and sets up a start command (type
  `web`) to run PHP FPM and HTTPD Server. It will expose the path to the file
  via a launch-time environment variable. Users need to declare the intention
  to use httpd.

* **php-nginx**:
  Sets up Nginx as the web server to serve PHP applications.
  * provides: none
  * requires: `php` at build; `php`, `php-fpm`, `nginx` at launch

  This buildpack generates `nginx.conf` and sets up a start command (type
  `web`) to run PHP FPM and Nginx Server. It will expose the path to the file
  via a launch-time environment variable. Users need to declare the intention
  to use nginx.


#### Proposed set up
This RFC proposes the following set of buildpacks to accomplish the
same task:

* **php-httpd**:
  Sets up HTTPD configuration to serve PHP applications.
  * provides: `httpd-config`
  * requires: none

  This buildpack generates `httpd.conf`. Users need to declare the intention to
  use httpd.

* **php-nginx**:
  Sets up Nginx configuration to serve PHP applications.
  * provides: `nginx-config`
  * requires: none

  This buildpack generates `nginx.conf`. Users need to declare the intention to
  use nginx.


* **php-start**:
  Sets the web server start command as well as the FPM start command.
  * provides: none
  * requires: `php`, `php-fpm` (optional), [`httpd`, and `http-config`] OR
    [`nginx` and `nginx-config`] at launch

  This buildpack sets up a start command (type `web`) to run HTTPD or Nginx,
  and potentially FPM in cases where both process should be run in the same
  container. In the cases where FPM should be run in it's own container, the
  FPM start command will be delegated to the PHP FPM Buildpack, and PHP Start
  will only start the web-server.

The order groupings in the PHP language family meta-buildapck from the original
Restructure RFC would be modified to include the new PHP Start buildpacks in
the HTTPD and Nginx order groups:
```toml
[[order]] # HTTPD web server

  [[order.group]]
    id = "paketo-buildpacks/php-dist"
    version = ""

  [[order.group]]
    id = "paketo-buildpacks/composer"
    version = ""
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/composer-install"
    version = ""
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/httpd"
    version = ""

  [[order.group]]
    id = "paketo-buildpacks/php-fpm"
    version = ""

  [[order.group]]
    id = "paketo-buildpacks/php-httpd"
    version = ""

  [[order.group]]
    id = "paketo-buildpacks/php-start"
    version = ""

    ...

[[order]] # Nginx web server

  [[order.group]]
    id = "paketo-buildpacks/php-dist"
    version = ""

  [[order.group]]
    id = "paketo-buildpacks/composer"
    version = ""
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/composer-install"
    version = ""
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/nginx"
    version = ""

  [[order.group]]
    id = "paketo-buildpacks/php-fpm"
    version = ""

  [[order.group]]
    id = "paketo-buildpacks/php-nginx"
    version = ""

  [[order.group]]
    id = "paketo-buildpacks/php-start"
    version = ""

    ...
```

## Rationale and Alternatives
One alternative is to keep the original proposal as is. This is less than ideal
for the reasons explained in this RFC, but it would reduce overall language
family complexity.

Another alternative would be to create separate HTTPD and NGINX start command
buildpacks. This would solve the modularity problem, but would leave the issue
of code duplication unaddressed.

## Prior Art
- [Original RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/php/0001-restructure.md)
- https://github.com/paketo-buildpacks/php/issues/503
- [PHP FPM Buildpack](https://github.com/paketo-buildpacks/php-fpm)
- [Original PHP Web Buildpack](https://github.com/paketo-buildpacks/php-web)
