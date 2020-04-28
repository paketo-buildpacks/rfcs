# Paketo Repo Migration Proposal

## Summary
Below we propose what repositories we will migrate into the paketo-buildpacks org.

## Implementation

#### NodeJS CNB (language family and implementation CNBs)
- nodejs (metabuildpack)
- node-engine
- yarn-install
- npm
 
#### Go CNB (language family and implementation CNBs)
- go (metabuildpack)
- go-compiler
- go-mod
- dep

#### Dotnet Core CNB (language family and implementation CNBs)
- dotnet-core (metabuildpack)
- dotnet-core-runtime
- dotnet-core-aspnet
- dotnet-core-sdk
- dotnet-core-build
- dotnet-core-conf
- icu

#### PHP CNB (language family and implementation CNBs)

- php (metabuildpack)
- php-web
- php-composer
- php-dist

#### Httpd CNB (language family and implementation CNBs)

- httpd

#### Nginx CNB (language family and implementation CNBs)

- nginx

#### Java CNB (language family and implementation CNBs)

- adopt-openjdk
- amazon-corretto
- apache-tomcat
- azul-zulu
- azure-application-insights (Java and NodeJS - - Implementations)
- bellsoft-liberica
- build-system
- debug
- dist-zip
- eclipse-openj9
- encrypt-at-rest
- executable-jar
- google-stackdriver (Java and NodeJS Implementations)
- jmx
- procfile
- sap-machine
- spring-boot

#### Libraries

- packit
- libpak
- libjvm

#### Other 

- builder formerly (cnb-builder)
- stacks
- build-common
- pipeline-builder
- samples

#### Libraries to be left out

- Python-cnb and all Python implementation CNBs
- libbuildpack or libcfbuildpack
- no shim-related code (cnb2cf, etc..)


### Buildpack Repo/ID/Name proposal:
We propose the following naming conventions for repositories, buildpack id's and registry path. 

### Repo:

Buildpack implementation repositories should be descriptively named and exclude any reference to "buildpack" or "Cloud Native Buildpack".

Ex:
	
	github.com/paketo-buildpacks/node-engine
	
### IDs:
The ID's of each buildpack ( in `buildpack.toml` ) should conform to the following.

	paketo-buildpacks/<name-without-cnb-suffix>

Here the `<name>` should be equivalent to the repository name in paketo-buildpacks, and follow the same conventions.


### Registry:

Buildpacks in the paketo org will also have a compiled and usable artifact available on GCR at the following paths:

	gcr.io/<id>

So for the `node-engine` buildpack this would be
	
	gcr.io/paketo-buildpacks/node-engine


### Stack Repo/ID/Name proposal:
Below is a plan for how the component pieces of stacks & builders should be named.

#### Builders
	gcr.io/paketo-buildpacks/builder:<builder-name>

#### Build Images
	gcr.io/paketo-buildpacks/build:<build-image-name>

#### Run Images
	gcr.io/paketo-buildpacks/run:<run-image-name>

