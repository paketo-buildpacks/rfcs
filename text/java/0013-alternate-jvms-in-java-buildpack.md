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

In addition to the current criteria for each buildpack, the detect method will also take the value of `BP_JVM_VENDOR` into account. If it is set, a buildpack should only detect if the value matches. BellSoft Liberica will remain the default JVM.

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

## Prior Art

- Offering alternate Java application servers in the composite java buildpack was implemented using an environment variable.  

## Unresolved Questions and Bikeshedding

- None
