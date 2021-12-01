# Auto-generate Reference Documentation

## Summary

We would like to make structural changes to the existing buildpacks
repositories in order to facilitate the generation of automated documentation
for each buildpack on the Paketo website.

## Motivation

Currently, users do not have access to the kind of documentation that they need
in order to use buildpacks efficiently. We feel that a set of comprehensive
reference documentation would give users the information that they need to get
the most of buildpacks and gain a deeper understanding on the level of
customization that is present in Paketo Buildpacks.

We feel that a set of comprehensive reference documentation would allow users
to see the full range of customization options. According to
[Divio](https://documentation.divio.com/reference/), the structure, tone, and
format of any reference documentation must be consistent and it must be
accurate and kept up-to-date. We believe the best way to accomplish this is
with automation. Since there are multiple buildpacks, we need to implement a
formal structure/process for each buildpack project that will allow seamless
automation and integration with the Paketo website.

The approach outlined in this RFC is motivated by recommendations specified by
Divio.  We found existing examples during our research to discover tools
designed to automate reference documentation. These include tools suchs as`go
docs`, `Doxygen`, and `Swagger UI`. Most of these tools were mainly designed
for code written in a specific language or for RESTful APIs. The design and
implementation of cloud-native buildpacks are unique and don't fit the
requirements for some existing automation tools since not all the documentation
will be dependent directly on the code or code comments. Designing a new
automation tool gives us the ability to fine tune how we want to display the
reference documentation on the Paketo website. It will also give maintainers
the ability to provide supplemental documentation if they want.

## Rationale and Alternatives

There are two ways to add reference documentation to the Paketo website:
1. Have maintainers create PRs to the Paketo website whenever there is a change
   to their respective buildpacks.
2. Create a tool that aggregates the documentation from the individual
   buildpack themselves automatically whenever there is a new change.

The first option makes it harder to maintain up-to-date documentation as this
would add an extra step for maintainers whenever they make a change to the
buildpack. With the second option, maintainers can update the docs within the
same commit as the changes.

## Implementation

In order to achieve automation we are proposing the creation of a new CLI tool
or the extension of an existing CLI tool (i.e. `jam` or `libpak/cmd`). This
tool will consume the structures in order to generate reference documentation
in the form of markdown. The first structure we are proposing to consume is the
`buildpack.toml` with inclusion of the `metadata.configurations` table array.
Examples of this field can be seen in the Java buildpacks such as [BellSoft Liberica](https://github.com/paketo-buildpacks/bellsoft-liberica):
```
api = "0.6"

[buildpack]
id       = "paketo-buildpacks/bellsoft-liberica"

...

[[metadata.configurations]]
name        = "BPL_JVM_HEAD_ROOM"
description = "the headroom in memory calculation"
default     = "0"
launch      = true

...

[[metadata.configurations]]
name        = "BP_JVM_TYPE"
description = "the JVM type - JDK or JRE"
default     = "JRE"
build       = true

...

[[metadata.dependencies]]
id      = "jdk"
name    = "BellSoft Liberica JDK"
version = "8.0.302"
uri     = "https://github.com/bell-sw/Liberica/releases/download/8u302+8/bellsoft-jdk8u302+8-linux-amd64.tar.gz"
sha256  = "23628d2945e54fc9c013a538d8902cfd371ff12ac57df390869e492002999418"
stacks  = [ "io.buildpacks.stacks.bionic", "io.paketo.stacks.tiny", "*" ]

  [[metadata.dependencies.licenses]]
  type = "GPL-2.0 WITH Classpath-exception-2.0"
  uri  = "https://openjdk.java.net/legal/gplv2+ce.html"

...
```

We propose that all maintainers add this configurations table array to their
buildpacks as a way of automatically generating information about the
environment variables that can be configured to modify the buildpacks'
behavior.

Additional documentation is parsed out of the `README.md` with all of the
content of the H2 level sections being appended after the environment variable
configuration. This parsing can be controlled the a `.docs.yml` that would
allow the buildpack maintainers to exclude certain H2 level sections of the
`README.md` from the final generated document. Below is an example of a
[`.docs.yml`](https://github.com/ForestEckhardt/bellsoft-liberica/blob/main/.docs.yml)
from a fork of the [Paketo BellSoft Liberica buildpack](https://github.com/ForestEckhardt/bellsoft-liberica/)

```yaml
exclude:
- "Configuration"
```

Below is an example snippet that was generated using a [POC CLI](https://github.com/ForestEckhardt/spikes/tree/main/auto-doc) and a fork of
the [Paketo BellSoft Liberica buildpack](https://github.com/ForestEckhardt/bellsoft-liberica).
---
# Paketo BellSoft Liberica Buildpack

## Environment Variable Configuration
### BPL_JVM_HEAD_ROOM
the headroom in memory calculation
Default Value: `0`
This environment variable is used during launch

...

### BP_JVM_TYPE
the JVM type - JDK or JRE
Default Value: `JRE`
This environment variable is used during build

## Behavior

This buildpack will participate if any of the following conditions are met

* Another buildpack requires `jdk`
* Another buildpack requires `jre`

The buildpack will do the following if a JDK is requested:

* Contributes a JDK to a layer marked `build` and `cache` with all commands on `$PATH`
* Contributes `$JAVA_HOME` configured to the build layer
* Contributes `$JDK_HOME` configure to the build layer

The buildpack will do the following if a JRE is requested:

* Contributes a JRE to a layer with all commands on `$PATH`
* Contributes `$JAVA_HOME` configured to the layer
* Contributes `-XX:ActiveProcessorCount` to the layer
* Contributes `-XX:+ExitOnOutOfMemoryError` to the layer
* Contributes `-XX:+UnlockDiagnosticVMOptions`,`-XX:NativeMemoryTracking=summary` & `-XX:+PrintNMTStatistics` to the layer (Java NMT)
* If `BPL_JMX_ENABLED = true`
  * Contributes `-Djava.rmi.server.hostname=127.0.0.1`, `-Dcom.sun.management.jmxremote.authenticate=false`, `-Dcom.sun.management.jmxremote.ssl=false` & `-Dcom.sun.management.jmxremote.rmi.port=5000`
* If `BPL_DEBUG_ENABLED = true`
  * Contributes `-agentlib:jdwp=transport=dt_socket,server=y,address=*:8000,suspend=n`. If Java version is 8, address parameter is `address=:8000`
* Contributes `$MALLOC_ARENA_MAX` to the layer
* Disables JVM DNS caching if link-local DNS is available
* If `metadata.build = true`
  * Marks layer as `build` and `cache`
* If `metadata.launch = true`
  * Marks layer as `launch`
* Contributes Memory Calculator to a layer marked `launch`
* Contributes Heap Dump helper to a layer marked `launch`
...

---
You can see the whole sample document generated [here](https://github.com/ForestEckhardt/spikes/blob/main/auto-doc/sample-output.md).

### Alternative To `README.md` Parsing
---
### `reference-doc.md`
Add an optional file included in
the project's root named `reference-doc.md`. The `reference-doc.md` file would
provide maintainers an opportunity to include supplemental documentation. For
example, maintainers might want to describe the build plan contract or caching
strategy, etc. We think that having an additional document that is clearly
named will make the process of adding and updating supplemental reference
documentation clear and approachable to new contributors.

#### Pros
It is a file that is placed at the root of the directory that has a name that
make ths the function obvious. This would hopefully make the addition of
relevant reference documentation easier for new contributors.

#### Cons
There would most likely be a duplication of documentation between the
`reference-doc.md` and the `README.md` which would increase the maintainence
overhead by making it necessary to maintain two sources of truth.

---
### Tagged Comments
Add the ability to tag code comments as comments that should also be added to
the reference documentation.
```go
func main() {
  some code
  // DOCUMENTATION: This will go in the reference documentation
  more code
}
```
#### Pros
The code and the documentation are intertwined making them useful for both a
buildpack author as well as a buildpack user.

#### Cons
The documentation is spread out and it is not immediately obvious to a new
contributor how to add new documentation to the reference documentation or how
it will be formatted.

## Prior Art

- [Divio Documentation Guide](https://documentation.divio.com/)
- [Investigation into reference documentation](https://github.com/paketo-buildpacks/paketo-website/issues/328)
- [`go docs`](https://go.dev/blog/godoc)
- [`Doxygen`](https://www.doxygen.nl/index.html)
- [`Swagger UI`](https://swagger.io/tools/swagger-ui/)

