# Paketo Repo Migration Proposal

## Summary
Below we propose what repositories we will migrate into the paketo-buildpacks org.

## Implementation

####NodeJS CNB (language family and implementation CNBs)

- node-engine
- yarn-install
- npm
 
####Go CNB (language family and implementation CNBs)

- go-compiler
- go-mod
- dep

####Dotnet Core CNB (language family and implementation CNBs)

- dotnet-core-runtime
- dotnet-core-aspnet
- dotnet-core-sdk
- dotnet-core-build
- dotnet-core-conf
- icu

####PHP CNB (language family and implementation CNBs)

- php-web
- php-composer
- php-dist

####Httpd CNB (language family and implementation CNBs)

- httpd

####Nginx CNB (language family and implementation CNBs)

-nginx

####Java CNB (language family and implementation CNBs)

- openjdk
- build-system
- jvmapplication
- apache-tomcat
- spring-boot 
- dist-zip
- procfile
- azure-application-insights (Java and NodeJS Implementations)
- debug
- googlestackdriver (Java & NodeJS Implementations
- jdbc
- jmx
- springautoreconfiguration
- executable-jar
- eclipse-open9
- sap-machine
- adopt-openjdk
- bellsoft-liberica
- encrypt-at-rest
- azul-zulu
- amazon-corretto

####Libraries

- packit
- libpak

#### Other repos
- builder formerly (cnb-builder)
- stacks
- github.com/ForestEckhardt/simple-paketo-node-app

#### Libraries to be left out

- Python-cnb and all Python implementation CNBs
- libbuildpack or libcfbuildpack
- no shim-related code (cnb2cf, etc..)


###Buildpack Repo/ID/Name proposal:
We propose the following naming conventions for repositories, buildpack id's and registry path. 

### Repo:

Buildpack implementation repositories should be descriptively named and exclude any reference to 'buildpack' or 'Cloud Native Buildpack'.

Ex:
	
	github.com/paketo-buildpacks/node-engine
	
###IDs:
The ID's of each buildpack ( in `buildpack.toml` ) should conform to the following.

	paketo-buildpacks/<name-without-cnb-suffix>

Here the `<name>` should be equivalent to the repository name in paketo-buildpacks, and follow the same conventions.


### Registry:

Buildpacks in the paketo org will also have a compiled and usable artifact available on GCR at the following paths:

	gcr.io/<id>

So for the `node-engine` buildpack this would be
	
	gcr.io/paketo-buildpacks/node-engine


###Stack Repo/ID/Name proposal:
Below is a plan for where the component pieces of stacks should live & how they should be named.

####Builders
	gcr.io/paketo-buildpacks/builder:<builder-name>

####Build Images
	gcr.io/paketo-buildpacks/build:<build-image-name>

#### Run Images
	gcr.io/paketo-buildpacks/run:<run-image-name>


