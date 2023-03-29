# Stacks & Extensions for UBI base images. (UBI8)

## Summary

A set of stacks based on the UBI base image should be developed, released, and maintained. 

Unlike the existing stacks, that come in "full", "base", and "tiny" the UBI stack will initially start with a 
single variant, with future variants to follow. The initial variant will have buildpacks for a handpicked set of 
runtimes that have been tested with UBI, and will make use of a number of CNCF Buildpack 'Extensions' that will be 
developed, released and maintained by the relevant teams to offer installation of selected runtimes and dependencies 
via rpm/dnf. These extensions will be packaged with the UBI builder to allow the customer the option of using the 
UBI provided runtimes. 

## Motivation

Red Hat Universal Base Images (UBI) are designed to be a foundation for cloud-native and web applications use cases 
developed in containers. UBI Images form a popular choice for base container images, and can even be preferred 
within environments with existing UBI deployments. In addition, use of a UBI image can sometimes be a requirement 
for an application qualifying for support from some vendors while in production. That requirement is also extended 
to any runtime in use, eg for Node or Java, the runtime must be installed via rpm/dnf, rather than via a tarball. 

## Detailed Explanation

### Background

There are a wide variety of UBI images offered by Red Hat, offering pre configured deployments of various runtimes 
(such as Java), and offering cutdown images designed for extension (ubi-minimal).

While it would be possible to use UBI images in a similar fashion to the existing Ubuntu based images, and have 
buildpacks perform the download & install of depdencies within layers, the preferred route would be to to use the 
dependencies supplied via the configured package repositories within the images. Eg, rather than downloading a 
JVM/JDK, one would be installed via 'yum' or 'dnf'. 

Until recently, CNCF Buildpacks were unable to effect changes to the Builder or Run image at a system level (eg, you
could not make modifications that required root from a buildpack, such as installing packages via yum). Recent 
updates to the Buildpacks project have added 'extensions', these can be considered as special variants of buildpacks 
that are able to modify the Builder image (and substitute the Run image), via generated Dockerfiles created during 
the execution of the Extensions. (In the future, the goal is to also allow modification of the Run image via the 
same mechanism).

Via extensions, it becomes possible to have a Builder image that can install dependencies such as Java, Maven,
NodeJS, etc via yum. These extensions are very similar to buildpacks, participating in the 'detect' phase, and 
being allowed to issue 'provides' to the buildplan (but critically not 'requires'). Then extensions that are
selected to become part of a build run a 'generate' task (rather than a buildpacks 'build' task), that may output 
Dockerfiles to modify the Builder image, and/or substitute the Run image. Just like buildpacks, the detect & 
generate invocations get access to the source project to determine what actions they wish to take. For more 
information on extensions see.. https://github.com/buildpacks/spec/blob/main/image_extension.md

### Initial offered image

The intent is provide an initial builder image that caters to Java & NodeJS runtimes (without Java Native). 
Some early prototyping has shown this to be possible using the existing Java & NodeJS builder ecosystems 
present within Paketo today, with Extensions installing the main runtime dependencies. 

In the case of Java, much work has already been done by Paketo to allow for different buildpacks to supply the 
JDK/JVM, making it relatively simple to extend this to allow an Extension to perform the same role. For NodeJS, there
were some small changes required, that have already been merged. 

The initial image will be labelled with a Stack ID of `io.buildpacks.stacks.ubi8` Note that much as Ubuntu
moves from release to release, so does UBI, and currently we will target UBI8, but want to ensure the naming allows
for the future addition for UBI9 and so on.

There will be no "intermediate" image as with Bionic, as the base builder image is intended to be a published
UBI8 image.

The initial image shall be considered as the 'base' variant, for the purposes of differentiation when/if 
subsequent images are published. 

### Image Naming and Tagging

The stack will name and tag the release images with the following pattern:

```
paketobuildpacks/{phase}-ubi8-{variant}:{version}
```

For example we could see the following images for UBI8 stacks:

* `paketobuildpacks/build-ubi8-base:latest`
* `paketobuildpacks/run-java-ubi8-base:1.2.3`
* `paketobuildpacks/run-nodejs-ubi8-base:1.2.3`

*Note the run image `phase` is narrowed by inclusion of the pre-packaged runtime. The correct image is 
selected at Build time by the appropriate Extension*

Each stack repository should include a README that outlines the stacks that are
available including links to each other repository allowing users to discover
the stack variants available from any of the stack repository pages.

#### Multi-arch

No specific plans for multi-arch are made as part of this RFC, with the initial stack starting within 
Paketo Community organisation, multi-arch can be revisited for this stack as the work progresses on the
Ubuntu stacks. There is nothing specific within this RFC that would tie this stack to particular architectures
beyond those supported by the upstream UBI images used as bases for the Builder/Run images. 

If there any multi arch concerns for Paketo UBI stacks, they are existing ones shared by Paketo 
already (eg, the Go detect/build binaries needing to be executable etc).

### Subsequent images..

It is likely that Native compilation for Java may require a different Builder image, as the requirements for 
native compilation are complex, and may require the Builder to extend an appropriate base image to provide 
the require capabilities in a supported manner. 

As additional runtimes are added to the initial image over time, it may make sense to follow the same 
general approach as the Ubuntu stacks have, and aim for a small but manageable number of stacks that meet definable 
use cases. (eg, 'one size fits all', 'just the most used runtimes')


## Rationale and Alternatives

With the goal in mind of creating a Stack based on UBI using system packaged depdencies, these alternatives 
have been considered...

#### Builders per Runtime
This option would have 1 Builder image per runtime, paired with a matching run image per runtime, with the runtime
depdencies baked into the builder/run images. This option did not require Extensions from upstream, but would 
result in a large collection of single purpose stacks which rapidly becomes unmanageable as you consider versioning
across runtimes (eg, there would likely need to be java 8,11,17 stacks). Exisiting Paketo buildpacks would be 
checked to ensure they would honor & use a dependency already in the builder image, over one the buildpack would
normally download & use.

In addition this transfers the responsibility of a lot of the 'magic' of Buildpacks to the end user, requiring them 
to know in advance which builder image to use with a given project, and to submit to the correct build pipeline, or
adapt the pipeline per project. 

#### 'Phat' Builder Image
This option would have 1 Builder image with many runtimes baked in, and then a selection of run images with
appropriate runtimes baked in that would be selected by the Builder via Extensions. As with the previous option, 
existing buildpacks would be checked to ensure they would use the baked in dependencies as a priority. 

This approach leads to a very large Builder image, which is suboptimal from an end user perspective, plus, as all 
runtimes are baked in, there would likely be frequent updates to the Builder image to incorporate fixes & security
updates to each contained runtime, leading to the end-user requiring a fresh version of the builder image for almost 
every update. A large image + frequent updates creates a less than ideal development experience.

#### UBI without rpms
This option would just take the existing Paketo buildpacks as-is and run them on a UBI base image. As with all the 
options here, testing would be required for all contained buildpacks to ensure any system or shell interactions were 
unaffected by the Ubuntu->UBI switch. 

Although this approach would produce functional application images, the resulting images would not be using UBI 
installed runtimes, and thus could be unable to qualify for full support in production. This is considered important 
enough to end users that this option was discarded.

### Chosen approach.
The chosen approach of using an empty Builder image with Extension installed depdencies via RPM meets the goals of 
having a lightweight development experience, while still being able to create supportable applications based on UBI 
images. 

## Implementation

The UBI stack will start within the Paketo Community organisation, to allow time for development and stabilization. 

### Repositories

The stacks team will create a new repo for UBI within the Paketo Community Organisation...

* `ubi-base-stack`

The buildpacks team will create two new repos within the Paketo Community Organisation for the initial two Extensions.

* `ubi-java-extension`
* `ubi-nodejs-extension`

The builders-maintainers team will create the repo within the Paketo Community Organisation for the Builder image

* `builder-ubi-base`

## Prior Art

No prior art for use of Extensions with Buildpacks to achieve this goal, beyond the prototypes created during 
the CNCF Buildpack Extension development.

## Unresolved Questions and Bikeshedding

* Although the provisioning of dependencies via rpm/yum is a goal here, note it is not proposed to block the 
use of dependencies downloaded via existing buildpacks. The rpm/yum behavior will be the default for the ubi stack. 

* Note that multi-runtime applications (where say both nodejs and java form the final application) are not 
covered by this stack. Although still achievable via end-user custom builders, it's not a goal for this incarnation. 

* To allow for rebasing, and to work with the current Extension support, it is required to publish **multiple** 
run images for a given builder image. This will likely require minor updates to the existing stack creation tooling. 

* It may be possible in future builders to support run image customization via rpm/yum, at the cost of 
losing rebasing support with the final application image. 

* How does the actual building & releasing of the stack image work? is this something configured onto the 
repo by the 'stacks team' on our behalf? 

* I'm guessing here at the teams that do things.. feel free to jump in and tell me where things actually get done =)
