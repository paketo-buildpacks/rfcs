#  Installation Buildpack BOM Generation

## Summary

Add support for the generation of the Bill of Materials in the NPM Install and
Yarn Install buildpacks in order to provide entries for modules installed
during the build process.

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
installation process to the package managers. Due to the nature of these
dependencies and how they are installed, the process of generating a Bill of
Materials will require changes to the installation buildpacks themselves.

This is an important piece of the Bill of Materials, because it gives a
complete picture of what dependencies are inside of the final application
image. Without this metadata, a major value-add of a Bill of Materials is lost
and users may have to use third-party tools to generate the rest of the BOM,
which is a less than ideal user experience.


## Implementation

### Tool details

The Bill of Materials that will result from the NPM/Yarn Install buildpacks
should be an accurate accounting of all of the modules that get installed into
the `node_modules` directory.

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

### Buildpack Additions

Using the CycloneDX tool to generate the BOM will involve some changes to the
NPM Install and Yarn Install Buildpacks.

* After the `npm install` or `yarn install` command is run during the build
  phase, we should run `npm install -g @cyclonedx/bom` to install the tool on
  the container.

* Run `cyclonedx-bom -o bom.json` from the working directory where the
  `node_modules` are located

* Implement some code to unmarshal the JSON Bill of Materials and transform
  each BOM entry into a
  [`postal.Dependency`](https://github.com/paketo-buildpacks/packit/blob/c5a40518f2c6bd913ade999b9e2d58d6892d2ea9/postal/buildpack.go#L12)
  type.

* (Optionally) generate `CPE` and `pURL` from the data and add it to the
  `postal.Dependency`.

* Run the
  [`postal.GenerateBillOfMaterials`](https://github.com/paketo-buildpacks/packit/blob/c5a40518f2c6bd913ade999b9e2d58d6892d2ea9/postal/service.go#L186)
  command.

* Add the resulting BOM to the `build` and/or `launch` metadata under the `BOM`
  field.

* Clean up the generated BOM file

## Alternatives and Rationale

Performing BOM generation with the CycloneDX Node.JS Module tool has some
advantages. First, it minimizes the extra code we would have to develop and
maintain to recurse through the nested `node_modules` directories and pull
information from each `package.json` file.

Second, there is a high likelihood that we will support CycloneDX as a BOM
format in the future. In that case, we can simply run the tool and return that
BOM without any additional formatting or conversion. Going this route will
minimize the change needed down the road, and we can get a CycloneDX output we
can feel confident about.

The alternative to this option would be to hand-create the BOM as described. We
could go through each nested `node_modules` directory, pull information out of
each `package.json` and then build out our own BOM with that data. This is a
viable option if installing a tool is not a reasonable choice.

## Resources

* Work in progress [Paketo BOM
  RFC](https://github.com/sophiewigmore/rfcs/blob/sophie/bom/text/0028-bill-of-materials.md)
* Work in progress [Cloud Native Buildpacks BOM Format
  RFC](https://github.com/buildpacks/rfcs/pull/166)
