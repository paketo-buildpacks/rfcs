# Create Java-specific builder

## Summary

Currently, Paketo provides the Full, Base and Tiny builders, which include different sets of buildpacks. While they are a simple way of packaging all the necessary components for a Paketo build, they often include more than a user actually needs. This proposal is to create a builder that contains only the buildpacks needed by the composite Java buildpack.  Buildpacks for other language families would not be included.  

## Motivation

The current builders have nearly reached the maximum layer limit for container images making it challenging to add new buildpacks. The ultimate goal is to include additional JVM providers in the Java composite buildpack as proposed in [#267 Add additional JVMs to the Java buildpack](https://github.com/paketo-buildpacks/rfcs/pull/267).

## Detailed Explanation
The maximum number of layers an image can have is 127.  The current full builder contains 103 layers providing little room for additional layers.  
A Java-specific builder with all 9 currently available JVM providers would contain 44 layers.  

## Rationale and Alternatives

One alternative is compressing the layers in the current builders as proposed in the [upstream RFC](https://github.com/buildpacks/pack/issues/1595).  There doesn't seem to be much interest for the proposal, however.  

Each buildpack adds one layer to the image.  If the 8 other JVM providers were included in the Java buildpack the number of layers would increase to 111.  Still within the 127 max but inching closer. Perhaps a smaller set of JVM providers could be added instead of all 8.

## Implementation

A new git repo would be created for a Java builder similar to the current builders.  A sample builder.toml:
```
description = "Ubuntu bionic base image with buildpacks for Java, including all JVM providers"


[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/bellsoft-liberica"  

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/eclipse-openj9"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/syft"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/gradle"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/maven"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/ca-certificates"     

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/oracle"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/alibaba-dragonwell"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/microsoft-openjdk"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/amazon-corretto"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/adoptium"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/sap-machine"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/azul-zulu"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/leiningen"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/clojure-tools"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/sbt"             

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/watchexec"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/executable-jar"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/apache-tomcat"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/apache-tomee"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/dist-zip"    

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/spring-boot"             

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/procfile"  

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/jattach"  

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/azure-application-insights"  

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/google-stackdriver"  

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/datadog"  

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/java-memory-assistant"  

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/encrypt-at-rest"  

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/environment-variables"  

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/image-labels"

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/liberty"  

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/bellsoft-liberica"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/eclipse-openj9"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/oracle"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/alibaba-dragonwell"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/microsoft-openjdk"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/amazon-corretto"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/adoptium"
    optional = true  

  [[order.group]]
    id = "paketo-buildpacks/sap-machine"
    optional = true  

  [[order.group]]
    id = "paketo-buildpacks/azul-zulu"
    optional = true                       

  [[order.group]]
    id = "paketo-buildpacks/syft"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/leiningen"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/clojure-tools"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/gradle"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/maven"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/sbt"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/executable-jar"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/apache-tomcat"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/apache-tomee"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/liberty"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/dist-zip"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/spring-boot"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/jattach"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/azure-application-insights"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/google-stackdriver"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/datadog"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/java-memory-assistant"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/encrypt-at-rest"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true

  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true

[stack]
  id = "io.buildpacks.stacks.bionic"
  build-image = "gcr.io/paketo-buildpacks/build:base-cnb"
  run-image = "gcr.io/paketo-buildpacks/run:base-cnb"    
```  

## Prior Art

unknown

## Unresolved Questions and Bikeshedding
