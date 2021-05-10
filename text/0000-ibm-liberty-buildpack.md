# Paketo Community IBM Liberty Buildpack

## Summary

Create a cloud native buildpack for the IBM [OpenLiberty](https://openliberty.io/) java runtime.  This buildpack will be included in a new multi/meta-buildpack.

## Motivation

A [ibm-websphere-liberty-buildpack](https://github.com/cloudfoundry/ibm-websphere-liberty-buildpack) exists in the cloudfoundry community and is widely used and popular.  This RFC will
take that buildpack to the next level, cloud native.  This buildpack will eventually replace the v2 CF ibm-websphere-buildpack.   

## Detailed Explanation

The IBM Liberty Buildpack will be based on the paketo apache-tomcat buildpack and contribute either the open source [OpenLiberty](openliberty.io) or the 
commercial [WebSphere Liberty](https://www.ibm.com/cloud/websphere-liberty).  The OpenLiberty runtime will be the default.  

## Rationale and Alternatives

There no currently available buildpack that provides the OpenLiberty runtime.  As IBM moves away from WebSphere Liberty in favor or OpenLiberty, we want to create a new cloud native buildpack 
instead of modifying the existing cloud foundry buildpack.  

## Implementation
The buildpack will include 2 versions of both open liberty and websphere liberty and be updated on a 4-week cycle to coincide with the 4-week liberty release cycle.  

Our intent is to provide a similar configuration as openliberty's [Dockerfile](https://github.com/OpenLiberty/ci.docker/blob/master/releases/21.0.0.4/full/Dockerfile.ubuntu.adoptopenjdk11). 

Avaiable configuration environment variables include:
BP_LIBERTY_VERSION - The version of Liberty specified as a specific release or use semver.  Default TBD.  
BP_LIBERTY_PACKAGE - For open liberty one of the following: full or kernel-slim. For websphere liberty one of the following: webProfile7, webProfile8, javaee7, javaee8, or kernel.  Default TBD. 
BP_LIBERTY_USE_WLP - Indicates that the WebSphere Liberty runtime should be use instead of Open Liberty.  Default false.  

The multi/meta-buildpack will include buildpacks similar to the java buildpack like maven, gradle, debug, environment variables.  

## Prior Art

This buildpack will contribute a liberty runtime similar to how the [ibm-websphere-liberty-buildpack](https://github.com/cloudfoundry/ibm-websphere-liberty-buildpack) provides the websphere 
liberty runtime in cloud foundry v2 buildpacks.  

## Unresolved Questions and Bikeshedding

Defaults need to be decided and defined. 

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
