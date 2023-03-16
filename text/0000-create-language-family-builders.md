# Create language family builders

## Summary

Currently, Paketo provides the Full, Base and Tiny builders, which include different sets of buildpacks. While they are a simple way of packaging all the necessary components for a Paketo build, they often include more than a user actually needs.  These "starter" builders served the purpose of making it easy to get started with Paketo buildpacks.  However, as users have become more sophisticated these all-in-one builders have become a hindrance.  

This proposal is to create builders that contains only the buildpacks needed by a language family.  Buildpacks for other language families would not be included. For all language families, the primary advantage to a language specific builder is the significant reduction in the size of the builder and increasing the speed to build.  

## Motivation

The current builders have nearly reached the maximum layer limit for container images making it challenging to add new buildpacks. The ultimate goal is to include additional JVM providers in the Java composite buildpack as proposed in [#267 Add additional JVMs to the Java buildpack](https://github.com/paketo-buildpacks/rfcs/pull/267).  

Additionally, a recently released version of the Full Builder (v0.2.278) contains 103 layers. When a user builds with the Full Builder building their app, all 103 layers must be pulled down locally.  The size of the builder and time to pull it down is considerable.  Using a language-specific builder we can greatly reduce the resources (size and speed) needed to run `pack build` and improve the user experience.  As a result, we encourage adoption of the Paketo buildpacks.

Finally, there are a set of APM buildpacks that are not natively available in the current builders.  A language family builder can include the APM buildpacks to make it easier for users to utilize these tools and facilitate adoption.

## Detailed Explanation
The maximum number of layers an image can have is 127.  The current full builder contains 103 layers providing little room for additional layers.  
A Java-specific builder with all 9 currently available JVM providers would contain 44 layers.  Each of the APM buildpacks would add an additional layer.

## Rationale and Alternatives

One alternative is compressing the layers in the current builders as proposed in the [upstream RFC](https://github.com/buildpacks/pack/issues/1595).  

Another alternative is adding fewer additional JVM provideds to the existing builders.  Each buildpack adds one layer to the image.  If the 8 other JVM providers were included in the Java buildpack the number of layers would increase to 111.  Still within the 127 max but inching closer. Perhaps a smaller set of JVM providers could be added instead of all 8.

A third alternative is to create a JVM meta-buildpack that contains all the JVM provider buildpacks and configures the JRE/JDK dependencies.   This would replace the current BellSoft Liberica buildpack.  

However, for all 3 alternatives, a language-specific builder still reduces the size (number of layers in the builder) and speed (downloading fewer buildpacks) of building applications and provides growing room to add additional buildpacks like the APMs.    

## Implementation

This RFC proposes a joint ownership of family-language builders.  Specifically, the builder team own the machinery/workflows to produce the images and the language teams own the actual builder.toml & any tests for validation.  Each language-family will maintain `builder.toml` files in separate repos to align with current tooling and existing repos.  Repo names will follow the convention:
```
builder-{distro}-{variant}-{language-family}
```
For example, the jammy full java family builder repo will be named: `builder-jammy-full-java`.

### Variants

The language family builders should align with the existing jammy-based builders and allow for future distributions like `ubi` and future ubuntu-based stacks.  
The builders will name and tag their release images with the following pattern:
```
builder-{distro}-{variant}-{language-family}:{version}
```
For example,
* `paketobuildpacks/builder-jammy-full-java:latest`
* `paketobuildpacks/builder-jammy-base-java:latest`
* `paketobuildpacks/builder-jammy-base-go:latest`
* `paketobuildpacks/builder-ubi-full-java:latest`

Note: Standard support of bionic ends April 2023 so it likely does not make sense to create builders based on bionic.   


The decision to create language family-specific builders is owned by each language family team. Teams may
decide to create zero or more based on their needs and user demand. In addition, each language-family team
owns the decisions about what goes into the builder. Again, this can be based on team and user needs.

A sample builder.toml for a Java language builder (without specific versions or the APM buildpacks):
```
description = "Ubuntu jammy base image with buildpacks for Java, including all JVM providers"


[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/bellsoft-liberica"  

[[buildpacks]]
  uri = "docker://gcr.io/paketo-buildpacks/eclipse-openj9"

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
  uri = "docker://gcr.io/paketo-buildpacks/java"  

[[order]]

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
    id = "paketo-buildpacks/java"
    optional = true

[stack]
  id = "io.buildpacks.stacks.jammy"
  build-image = "docker.io/paketobuildpacks/build-jammy-full:latest"
  run-image = "index.docker.io/paketobuildpacks/run-jammy-full:latest"   
```  

## Publishing
The language family builders should be pushed to Dockerhub and gcr like the current builders and be presented in the output of `pack builders suggest`.

## Documentation
The current README.md's for each builder and the Paketo website need to be updated to clarify what each builder provides.  Blog posts should also be written to announce the availability of the language-specific builders, there advantages and how to use them.  

## Prior Art

unknown

## Unresolved Questions and Bikeshedding
How or does this affect the java-native buildpack?
Each language family will need to decide which stack they will be built on top of, base or tiny.  
