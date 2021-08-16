#  Installation Buildpack BOM Generation

## Summary

Add support for the generation of the Bill of Materials in the Node Language
Family in order to provide entries for modules installed
during the build process that can be found on the final app image.

## Motivation

As a part of an initiative to provide a Bill of Materials (BOM) in the Node.JS
Language Family, we have to support BOM generation in both buildpacks that
directly install dependencies (Node Engine and Yarn), as well as in buildpacks
that run an installion command that results in a set of installed dependencies
(NPM Install and Yarn Install)

For the directly installed dependencies in the Node Engine and Yarn buildpacks,
we control the metadata around the dependencies and largely implemented BOM
metadata retrieval on the dependency server side. The availability of this
metadata made it straightforward to consume the metadata and generate the BOM.

For the indirectly installed modules that are installed by the NPM Install and
Yarn Install buildpacks, this is not the case because we delegate the
installation process to the package managers. The case in which we have no
package manager and use vendored node modules also falls under this case. Due
to the nature of these dependencies and how they are installed, the process of
generating a Bill of Materials will require changes to the language family itself.

This is an important piece of the Bill of Materials, because it gives a
complete picture of what dependencies are inside of the final application
image. Without this metadata, a major value-add of a Bill of Materials is lost
and users may have to use third-party tools to generate the rest of the BOM,
which is a less than ideal user experience.


## Implementation

### Tool details

The Bill of Materials that will result should be an accurate accounting of all
of the modules that get installed into the `node_modules` directory.

There already exists a tool called [CycloneDX Node.js
Module](https://github.com/CycloneDX/cyclonedx-node-module) which is an
official CycloneDX supported-tool that creates valid CycloneDX BOMs for Node.JS
applications. CycloneDX is a BOM format supported by the OWASP Foundation, and
is a serious contender (at the time of this RFC creation) as a format we will
eventually support.

The CycloneDX Node.js Module tool can easily be installed via `npm install` and
then run from a directory containing `node_modules`. The output BOM contains
the following fields for each module:
* name,
* version,
* description,
* hash,
* source URI,
* license ID,
* and package URL

All of these are fields that we aim to support per [the Paketo BOM
RFC](https://github.com/sophiewigmore/rfcs/blob/8b1e8c9ed6201313f47c5897223cbffb265e96ed/text/0028-bill-of-materials.md)

In order to support this tool in both the online and offline cases, we will
pre-compile the tool with it's dependencies, and provide it as a dependency
hosted on the [dep-server](https://github.com/paketo-buildpacks/dep-server).

### Language Family Additions

Using the CycloneDX tool to generate the BOM will involve some changes to the
Node.JS language family buildpack order groups.

* A single BOM generation buildpack will be added. It's primary functions are:
  * perform the BOM dependency tool retrieval from the dep-server,
  * execute BOM generation with the tool (`cyclonedx-bom -o bom.json`), and
  * contribute the BOM to the `launch.toml` `[bom]` label.

* For each of the three Node.JS buildpack order groups, the BOM generation
  buildpack will run directly before the start command buildpack. This means:
  * directly before the `yarn-start` buildpack in the Yarn order group,
  * directly before the `npm-start` buildpack in the NPM order group, and
  * directly before the `node-start` buildpack in the no-package-manager order group.

#### Detection

The Node Module BOM Generator CNB always detects with the following contract:
  * Requires {`node`, `node_modules`} during `build`
  * Provides none

Detection will also pass if there is a vendored `node_modules` directory in the source
directory. The contract changes to:
  * Requires `node` during `build`
  * Provides none

#### Build

The build phase will perform a few tasks as mentioned above.

1. Perform the BOM dependency tool retrieval from the dep-server. It will get
   added to a build-time layer. It will contribute a BOM entry for the tool itself
   on the `build.toml` `[bom]` section.

2. Execute BOM generation with the installed tool via the `cyclonedx-bom -o
   bom.json` command on the application `node_modules` directory. It will
   contribute BOM entries for every node module.

3. Unmarshal the CycloneDX JSON BOM and transform each BOM entry into a
   [`postal.Dependency`](https://github.com/paketo-buildpacks/packit/blob/c5a40518f2c6bd913ade999b9e2d58d6892d2ea9/postal/buildpack.go#L12)
   type. This step and step 5 will eventually go away if we support CycloneDX
   as a BOM format.

4. (Optionally) generate `CPE` and `pURL` from the data and add it to the
  `postal.Dependency`.

5. Run the
  [`postal.GenerateBillOfMaterials`](https://github.com/paketo-buildpacks/packit/blob/c5a40518f2c6bd913ade999b9e2d58d6892d2ea9/postal/service.go#L186)
  command.

6. Clean up the generated BOM file

#### Potential Future Optimizations

Given future user interest in a way to opt out of this buildpack beyond a
custom order grouping, an optimization that could be made is the inclusion of a
`BP_ENABLE_MODULE_BOM` environment variable that can be set during container
build-time.

## Rationale

Performing BOM generation with the CycloneDX Node.JS Module tool has some
advantages. First, it minimizes the extra domain knowledge we would have to
develop and maintain a program to recurse through the nested `node_modules`
directories and pull information from each `package.json` file.

Second, there is a high likelihood that we will support CycloneDX as a BOM
format in the future. In that case, we can simply run the tool and return that
BOM without any additional formatting or conversion. Going this route will
minimize the change needed down the road, and we can get a CycloneDX output we
can feel confident about.

## Alternatives

An alternative to the option to using the CycloneDX BOM tool would be to
hand-create the BOM as described. We could go through each nested
`node_modules` directory, pull information out of each `package.json` and then
build out our own BOM with that data. This is a viable option if installing a
tool is not a reasonable choice.

An alternative to performing all of these steps in a separate buildpack would
be to add the CycloneDX tool installation as a step in the Node Engine
buildpack, and then run BOM creation alone in a buildpack before the start
commands. This is less than ideal because it's not transparent or intuitive to
install it during the node-engine specific build process. It makes more sense
to separate all module BOM creation logic into its own buildpack, so that users
may easily opt out.

## Resources

* [Paketo BOM RFC](https://github.com/sophiewigmore/rfcs/blob/sophie/bom/text/0028-bill-of-materials.md)
* Work in progress [Cloud Native Buildpacks BOM Format
  RFC](https://github.com/buildpacks/rfcs/pull/166)
