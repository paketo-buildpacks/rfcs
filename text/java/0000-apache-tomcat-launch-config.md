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

TODO
{{Discuss 2-3 different alternative solutions that were considered. This is required, even if it seems like a stretch. Then explain why this is the best choice out of available ones.}}

## Implementation

The implementation will add a helper to the tomcat buildpack that will look for launch variables named `BPL_TOMCAT_ENV_*`, e.g. `BPL_TOMCAT_ENV_POSTGRES_URL`, the helper 
will take that variable, convert it to the system property `postgres.url` and append it to the environment variable `JAVA_TOOL_OPTIONS`.

## Prior Art

At present we've not found anything similar to this.

## Unresolved Questions and Bikeshedding

* Sensitive variables may be exposed in the application logs.

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
