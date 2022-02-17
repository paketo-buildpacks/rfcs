# Paketo Community Apache Tomee Buildpack

## Summary

1. Create a Cloud Native Buildpack for the purpose of installing the [Apache Tomee](https://tomee.apache.org/) Java application server.

## Motivation

An [Apache Tomcat](https://github.com/paketo-buildpacks/apache-tomcat) exists in the paketo community. This RFC will create an 
[Apache Tomee](https://tomee.apache.org) buildpack which will be based on the Tomcat buildpack so that users can replace Tomcat with
Tomee as an alternative application server.

## Detailed Explanation

### Apache Tomee Buildpack

This buildpack has the purpose of installing Apache Tomee. It will will be based on the Paketo [apache-tomcat](https://github.com/paketo-buildpacks/apache-tomcat) buildpack. 

This buildpack will participate if all the following conditions are met:

- `<APPLICATION_ROOT>/WEB-INF` exists or
- `Main-Class` is NOT defined in the manifest
- `BP_JAVA_APP_SERVER` is set to `tomee`

The buildpack will do the following:

- Requests that a JRE be installed
- Installs Apache Tomee
- Contributes tomee, task, and web process types

## Rationale and Alternatives

Other alternatives could be to enhance the existing tomcat buildpack with the options to install Apache Tomee instead of Tomcat.

## Implementation

The buildpack.toml will include 12 versions of Apache Tomee. There are three active major version streams `7`, `8` & `9`. Each releasing 4 different distributions 
of Apache Tomee: `webprofile`, `microprofile`, `plus` and `plume`.
  
Apache Tomee released under the [Apache License - v2](https://github.com/apache/tomee/blob/master/LICENSE) and will be included in the buildpack.toml.
  
```
  [[metadata.dependencies.licenses]]
  type = "Apache 2"
  uri  = "https://raw.githubusercontent.com/apache/tomee/main/LICENSE"
``` 
Our intent is to provide a similar configuration as [Apache Tomcat](https://github.com/paketo-buildpacks/apache-tomcat). 

Available configuration environment variables include:
* `BP_TOMEE_VERSION` - The specific version of Apache Tomee in the form x.x.x (example 7.1.4) or `Y.*` where Y is the major version. Default `8.*`
* `BP_TOMEE_DISTRIBUTION` - The distribution of Apache Tomee to install, can be one of `webprofile`, `microprofile`, `plus` or `plume`. Default `webprofile`
* `BP_TOMEE_CONTEXT_PATH` - The context path to run the application at. Defaults to ROOT
* `BP_TOMEE_EXT_CONF_SHA256`, `BP_TOMEE_EXT_CONF_STRIP`, `BP_TOMEE_EXT_CONF_URI` & `BP_TOMEE_EXT_CONF_VERSION` - Options to allow a configuration overlay, follows the same pattern as Apache Tomcat.
* `BP_TOMEE_ACCESS_LOGGING_ENABLED` - Enable the access logging, follows the same pattern as Apache Tomcat. 

Updates to buildpack dependencies will be provided by the [tomee-dependency action](https://github.com/paketo-buildpacks/pipeline-builder/tree/main/actions/tomee-dependency).

## Unresolved Questions and Bikeshedding

* Are 12 versions of Tomee too much? We could start with `webprofile` and add more if there is a need.
* POC - https://github.com/garethjevans/apache-tomee

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
