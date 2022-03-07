# Apache Tomcat launch configuration

## Summary

With the current implementation of the Apache Tomcat buildpack, its quite difficult to configure values at launch time that affect values in the `web.xml`, `server.xml` & `context.xml`. We 
want to provide a way to make some features easily configurable and controlled at launch time rather than build time.

## Motivation

The Apache Tomcat buildpack provides a method of adding a configuration overlay using the build time `BP_TOMCAT_EXT_CONF_*` variables, this takes a pre-built archive
and extracts this during build time. This method can be cumbersome if there are values that need to be changed on a per-deployment basis.  Apache Tomcat already supports
the use of [system property replacements](https://tomcat.apache.org/tomcat-9.0-doc/config/systemprops.html#Property_replacements) within its configuration files.  The aim is to make
the configuring of the system properties at launch time lot easier.
 
## Detailed Explanation

Given an example `context.xml`, which can be included in either an external archive, or inside the applications `META-INF` directory:

```
<Context>
    <Resources allowLinking="true"/>

    <Resource name="jdbc/Datasource" auth="Container"
              type="javax.sql.DataSource" driverClassName="org.postgresql.Driver"
              url="${postgres.url}" username="${postgres.username}"
              password="${postgres.password}" maxTotal="25"
              maxIdle="10" validationQuery="select 1"/>

</Context>
```

The resource configuration is static apart from the `url`, `username` and `password` parameters, but we do not want these to be written into the image at build time.

## Rationale and Alternatives

It is possible to use `BPE_*` parameters with the [environment variables buildpack](https://github.com/paketo-buildpacks/environment-variables), these are written into the image at buildtime.

These values could also be configured by updating `JAVA_TOOL_OPTIONS` variable, but this can be quite cumbersome and error prone if there are multiple values to configure, or if this env var already
contains configuration.

## Implementation

### At build time:

* Copy the included `resources/catalina.properties` into `$CATALINA_BASE/conf/catalina.properties`
* Ensure that `$CATALINA_BASE/conf/catalina.properties` is group writable

### At launch time:

* Read the location of the `$CATALINA_BASE/conf/catalina.properties` using the `$CATALINA_BASE` env var
* Read from all bindings and append values to `$CATALINA_BASE/conf/catalina.properties.`
* Read from all environment variables named `BPL_TOMCAT_ENV_*` and append values to `$CATALINA_BASE/conf/catalina.properties.`


The process of taking an enviromnent variable and converting it to a system property will be as follows:

Pseudocode:
```
	systemProperty = envVar.removePrefix('BPL_TOMCAT_ENV_').toLowerCase().replaceAll('_', '.')
```

## Prior Art

At present we've not found anything similar to this.

## Unresolved Questions and Bikeshedding

* The (proposed) Apache Tomee buildpack would also benefit from supporting this.

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
