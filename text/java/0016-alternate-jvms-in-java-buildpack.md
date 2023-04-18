# Add additional JVMs to the Java buildpack

## Summary

The default JVM in the Java buildpack is the Liberica JVM.  To use an alternative JVM requires specifying two --buildpack arguments on the `pack build` command.  

This RFC proposes a simpler method by defining an environment variable to specify which JVM provider to use.  This would be similar to how the Java Buildpack uses `BP_JAVA_APP_SERVER` to specify an alternate java application server to use instead of the default, apache tomcat.  

## Motivation

There are a few motivations for this change:

1. Using an alternate JVM is tedious.  
2. The preferred JVM for the Liberty application server is eclipse openj9 because there are features in it that the liberty server takes advantage of we would like to exploit in the liberty buildpack.
3. The alternate JVM buildpack runs before the CA certs buildpack and therefore traffic from the alternate JVM vendor buildpack won’t trust any additional CA certs.  
4. Easier adoption of the other JVM buildpacks.

## Detailed Explanation

Currently, the Java buildpack only contributes the BellSoft Liberica JVM.  If we can accommodate multiple JVMs then we can provide a more
well-rounded java buildpack, reach more Java communities, generate more interest in Paketo and Cloud Native buildpacks, and ultimately make it easier for users to build images for Java applications.

## Rationale and Alternatives

Alternatives:

- Do nothing. Users of the Java buildpack will have to manually create a builder or manually specify the buildpack order, which is tedious.
- Create new composite buildpacks other JVMs as the default.

## Implementation

In a composite buildpack all the JVM buildpacks will detect true to indicate they can provide a JRE/JDK.  At build time, all JVM buildpacks are free to contribute if the buildplan entry is not met and `BP_JVM_VENDOR` is set to their tag or not set at all. Buildpacks execute in the order they are defined. The bellsoft-liberica buildpack comes first, which preserves the current default behaviour.

| JVM                | tag          	| Buildpack                           |
| ------------       | ------------ 	| ------------------------------------|
| BellSoft Liberica  | liberica       |  bellsoft-liberica  buildpack       |
| Eclipse Openj9     | openj9         |  eclipse-openj9 buildpack           |
| Microsoft OpenJDK  | ms-openjdk     |  microsoft-openjdk buildpack        |
| Oracle             | oracle         |  oracle buildpack                   |
| Amazon Corretto    | corretto       |  amazon-corretto                    |
| Adoptium           | adoptium       |  adoptium buildpack                 |
| SAP Machine        | sapmachine     |  sap-machine buildpack              |
| Alibaba Dragonwell | dragonwell     |  alibaba-dragonwell buildpack       |
| GraalVM            | graalvm        |  graalvm buildpack                  |
| Azul Zulu          | azul-zulu      |  azul-zulu buildpack                |

Additional JVMs can easily be added to the Java buildpack by implementing this RFC.  

Initially, this RFC should be implemented in the new language family builder.  If and when the layer limit issue is resolved more JVM providers can be added to the main Paketo builders.    

## Prior Art

- Offering alternate Java application servers in the composite java buildpack was implemented using an environment variable.  

## Unresolved Questions and Bikeshedding

- None
