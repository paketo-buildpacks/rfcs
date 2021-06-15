# Paketo Community Liberty Buildpack

## Summary

1. Create a Cloud Native Buildpack for the purpose of installing the [Open Liberty](https://openliberty.io/) Java runtime. 
2. Create a new top-level multi buildpack that packages up Eclipse OpenJ9 & Open Liberty for use by application developers.

## Motivation

A [ibm-websphere-liberty-buildpack](https://github.com/cloudfoundry/ibm-websphere-liberty-buildpack) exists in the cloudfoundry community and is widely used and popular.  This RFC will
take that buildpack to the next level, cloud native.  This buildpack will eventually replace the v2 CF ibm-websphere-buildpack.   

## Detailed Explanation

### Open Liberty Buildpack

This buildpack has the purpose of installing the Open Liberty. It will will be based on the Paketo [apache-tomcat](https://github.com/paketo-buildpacks/apache-tomcat) buildpack. 

This buildpack will participate if all the following conditions are met:

- `<APPLICATION_ROOT>/WEB-INF` exists or
-  A liberty server directory exists
      a server.xml exists in the --path  or
-  A liberty packaged server exists 
	  an unarchived zip file exists containing a wlp/usr/servers/*/server.xml in the --path and
- `Main-Class` is NOT defined in the mainfest

The buildpack will do the following:

- Requests that a JRE be installed
- Installs [Open Liberty](openliberty.io) unless `BP_LIBERTY_USE_WLP` is `true` then it installs [WebSphere Liberty](https://www.ibm.com/cloud/websphere-liberty).
- Contributes liberty, task, and web process types

### Java-liberty Buildpack

This buildpack has the purpose of being a multi buildpack which defaults to using Eclipse OpenJ9 and Open Liberty. It will be a copy of the [Java](https://github.com/paketo-buildpacks/java) buildpack, but will substitute Eclipse OpenJ9 as the default JVM and it will swap Apache Tomcat in favor of Open Liberty. The proposed name is `java-liberty`.

## Rationale and Alternatives

There is no currently available buildpack that provides the Open Liberty runtime.  As IBM moves away from WebSphere Liberty in favor or Open Liberty, we want to create a new cloud native buildpack 
instead of modifying the existing cloud foundry buildpack.  

## Implementation
The buildpack.toml will include 2 versions of both Open liberty and Websphere Liberty and be updated on a 4-week cycle to coincide with the 4-week Liberty release cycle.  
Open Liberty is released under the [Eclipse Public License - v1.0](https://raw.githubusercontent.com/OpenLiberty/open-liberty/master/LICENSE) and will be included in the buildpack.toml.
  
```
  [[metadata.dependencies.licenses]]
  type = "EPL-1.0"
  uri  = "https://raw.githubusercontent.com/OpenLiberty/open-liberty/master/LICENSE"
``` 
Our intent is to provide a similar configuration as Open Liberty's [Dockerfile](https://github.com/OpenLiberty/ci.docker/blob/master/releases/21.0.0.4/full/Dockerfile.ubuntu.adoptopenjdk11). 

Available configuration environment variables include:
* BP_LIBERTY_VERSION - The specific version of Liberty in the form xx.x.x (example 21.0.6) or `YY.*` where YY is the current year and the latest Liberty version will be contributed.  Default is the latest buildpack.  
* BP_LIBERTY_PACKAGE_TYPE - The set of Liberty features to contribute.   For Open Liberty one of the following: full or kernel-slim. For websphere liberty one of the following: webProfile7, webProfile8, javaee7, javaee8, or kernel.  Default TBD. 
* BP_LIBERTY_USE_WLP - Indicates that the WebSphere Liberty runtime should be use instead of Open Liberty.  Default false.  

## Prior Art

This buildpack will contribute a liberty runtime similar to how the [ibm-websphere-liberty-buildpack](https://github.com/cloudfoundry/ibm-websphere-liberty-buildpack) provides the websphere 
liberty runtime in cloud foundry v2 buildpacks.  

## Unresolved Questions and Bikeshedding

* Defaults need to be decided and defined. 
* WebSphere Liberty is not open source and is subject to a commercial license.  How can we deal with that in a Paketo buildpack?
* What are the API specifications for the automation tooling to check for new releases and create a PR? 

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
