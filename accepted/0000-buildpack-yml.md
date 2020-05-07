# Buildpack YAML specification

## Summary
The `buildpack.yml` file should conform to a specified interface. The specification that follows provides both a generic schema and descibed the planned future format for buildpacks currently in the `paketo-buildpacks` and `paketo-community` orgs.

## Motivation
The `buildpack.yml` file is a public API that users will want to fit a rational and guessable form. Aligning all Paketo buildpacks with this form will help to rationalize this API. Additionally, it enables  users to guess where certain configuration settings might be defined, leading to a smoother feature discovery process.

## Detailed Explanation
We propose that the `buildpack.yml` file conform to the following schema.

### Schema
```yaml
<language-family>:
  <implementation>:
    <key>: <value>
```

All configuration is grouped under a language-family namespace, and then logically grouped under an implementation buildpack namespace which "owns" that configuration. Naturally, buildpacks that do not "own" that configuration should also be able to rely upon this schema to discover settings for other parts of the build process.

For example, the PHP language family consumes both `nginx` and `httpd` as web servers. The `php-web` buildpack would need a mechanism to discover which web server the user desires to use in their application so that it can configure PHP correctly for that web server. If these fields are standardized, then the `php-web` buildpack can detect that `nginx` is the server chosen if there is a `web-server.nginx` key in the `buildpack.yml` file.
 

## Rationale and Alternatives

The rationale for choosing this format is that language-family and implementation namespaces are currently the only mechanism for grouping configuration settings that can be consumed by buildpacks.

An alternative to this type of grouping would be to allow buildpack authors to choose any mechanism that fits their own needs. Those systems, being unstandardized, would be difficult to integrate and likely lead to incompatibilities of buildpacks that may rely upon the same keys for different configuration settings.

### Decision Points

#### Should all keys be listed under a language family?
It logically groups configuration for a buildpack family and reduces top level key pollution.


## Implementation

Below, we have completed a survey of the existing `buildpack.yml` properties, aligned to the schema, for each language-family.

### Language Families

#### Node.js
```yaml
nodejs:
  engine:
    version: <semver>
    optimized-memory: <bool>
  npm: #we don't support this at all
    version: <semver>
  yarn: # unsupported right now
    version: <semver>
```

#### .Net Core
```yaml
dotnet-core:
  sdk:
    version: <semver>
  aspnet:
    version: <semver>
  runtime:
    version: <semver>
  build:
    project-path: <string> # currently supported might need to change
    projects: #listing of targets to be built during a dotnet core build
    - <string>
    - <string>
```

#### PHP
```yaml
php:
  dist:
    version: <semver>
  web: # currently unsupported, all keys underneat this are also unsupported.
    directory: <string> #currently under the php key as 'webdirectory'
    script: <string> 
    libdirectory: <string>
    serveradmin: <string>
    enable_https_redirect: <bool>
    redis:
      session_store_service_name: <string>
    memcached:
      session_store_service_name: <string>
  web-server: <string> # REMOVE: should be deduced by the presense of nginx or httpd
```

#### Go
```yaml
go: 
  compiler: # go refers to the `go` binary as the go distribution, might be worth renaming
    version: <semver>
  build: #implies a change in go family architecture, here a final go-build buildpack actually builds the binary.
    import-path: <string>
    ldflags:
      <string>: <string>
      <string>: <string>
    targets:
    - <string>
    - <string>
```

#### Ruby
``` yaml
ruby: # net new, currently unsupported.
  mri:
    version: <semver>
  bundler:
    version: <semver>
```

#### Web Server
```yaml
web-server: # net new top level key, currently unsupported
  nginx:
    version: <semver>
  httpd:
    version: <semver>
```

### Steps

1. Language families should be reviewed to identify all properties that will need to be realigned.
2. Issues or PRs should be opened to address moving each property, taking into account that the property might need to be "deprecated" so that users will not have a terrible experience once the property moves to its new location.
3. Once all properties have been realigned for a language family, properties should be documented and outlined for users and buildpack authors.

## Unresolved Questions and Bikeshedding

1. Is `buildpack.yml` the right name?

