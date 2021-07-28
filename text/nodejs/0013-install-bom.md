#  Installation Buildpack BOM Generation

## Summary

Add support for the generation of the Bill of Materials in the NPM Install and
Yarn Install buildpacks in order to provide entries for modules installed
during the build process.

## Motivation

As a part of an initiative to provide a Bill of Materials (BOM) in the Node.JS
Language Family, we have to support generation in both buildpacks that directly
install dependencies (Node Engine and Yarn), as well as in buildpacks that run
an installion command that results in a set of installed dependencies (NPM
Install and Yarn Install)

For the directly installed dependencies in the Node Engine and Yarn buildpacks,
we control the metadata around the dependencies and largely implemented this on
the dependency server side. The availability of this metadata made it
straightforward to consume the metadata and generate the BOM.

For the indirectly installed modules that are installed by the NPM Install
and Yarn Install buildpacks, this is not the case because we delegate the
installation process to the package managers. Due to the nature of these
dependencies and how they are installed, the process of generating a Bill of
Materials will require changes to the installation buildpacks themselves.

This is an important piece of the Bill of Materials, because it gives a
complete picture of what dependencies are inside of the final application
image. Without this metadata, a major value-add of a Bill of Materials is lost
and users may have to use third-party tools to generate the rest of the BOM,
which is a less than ideal user experience.

## Proposal

TODO: Use https://github.com/CycloneDX/cyclonedx-node-module

## Implementation

TODO: describe how this will work

## Alternatives

TODO: do it by hand

## Prior Art

TODO: RFC
