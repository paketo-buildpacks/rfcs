# Support for CycloneDX and Syft SBoM in Paketo

## Summary

Buildpacks which directly provide a dependency or buildpacks which install
application dependencies will support the generation of SBoM in the format of
CycloneDX and Syft. Per [CNB
RFC#95](https://github.com/buildpacks/rfcs/blob/main/text/0095-sbom.md), the
SBoM documents will live at `<layer>.bom.<ext>.json`, `launch.bom.<ext>.json`
and `build.bom.<ext>.json` where `<ext>` will be `cdx` (CycloneDX) or
`syft` (Syft).

## Motivation

[Paketo
RFC#33](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0033-bill-of-materials.md)
describes the initial strategy used to add support for SBoM generation in
Paketo buildpacks. This RFC outlines the process by which Paketo buildpacks
will build upon that initial strategy by including support for CycloneDX and
Syft SBoM formats in accordance with the structure proposed in [CNB
RFC#95:SBOM](https://github.com/buildpacks/rfcs/blob/main/text/0095-sbom.md).

## Detailed Explanation

Paketo buildpacks may produce SBoM for runtime & application dependencies in
CycloneDX and Syft formats. SBoM information may be provided in three
locations, namely `<layers>/<layer>.bom.<ext>.json`, `<layers>/launch.bom.<ext>.json` and
`<layers>/build.bom.<ext>.json`, where <ext> is `cdx` for CycloneDX or `syft` for Syft
formats. The preferred content of these files is outlined below:

- `<layer>.bom.<ext>.json`: This file should be used only for SBoM information
  that is specific to a layer. This allows for greater specificity on the
  origin of the SBoM metadata, including which layer it relates to and which
  buildpack created the layer. Storing metadata here also potentially reduces
  overhead incurred by SBoM generation as the file would follow the lifecycle
  of the layer itself in terms caching and reuse.

- `launch.bom.<ext>.json`: This file should contain SBoM entries for
  dependencies which are contributed to the app image, but are not necessarily
  scoped to a specific layer. SBoM information stored here is ephemeral and
  would need to be regenerated on each build.

- `build.bom.<ext>.json`: This file should contain SBoM entries for
  dependencies which are contributed to the build environment, but are not
  necessarily scoped to a specific layer. SBoM information stored here is
  ephemeral and would need to be regenerated on each build.

**Note:** The above schema is not a hard requirement. What each of these files
consists of is ultimately the buildpack author's decision. Additional context
can be found
[here](https://github.com/buildpacks/rfcs/blob/main/text/0095-sbom.md#what-it-is).


Buildpack authors will also need to specify which SBoM formats are supported by
a given buildpack via `buildpack.toml`. This should look like:

```toml
api = "0.x"

[buildpack]
id = "<buildpack ID>"
name = "<buildpack name>"
# This can be an array of supported SBOM formats by the buildpack.
# Valid array values are sbom media types based on https://www.iana.org/assignments/media-types/media-types.xhtml
sbom = ["application/vnd.cyclonedx+json", "application/vnd.syft+json"]
```

### SBoM Formats

#### Syft

The minimum set of Syft fields that will be initially supported is represented
below. It is possible that additional fields will be supported in the future.

```json
{
 "artifacts": [
  {
   "id": <Syft-generated UUID string for in-file dependency graphing>,
   "name": <dependency name>,
   "version": <dependency version>,
   "licenses": [<dependency license ID(s) in SPDX-format>],
   "cpes": [<version-specific common platform enumerations>],
   "purl": [<package URL per github.com/package-url>]
  }
 ],
 "descriptor": {
  "name": "syft",
  "version": <Syft version>
 },
 "schema": {
  "version": "1.1.0",
  "url": "https://raw.githubusercontent.com/anchore/syft/main/schema/json/schema-1.1.0.json"
 }
}
```

#### CycloneDX

The minimum set of CycloneDX fields that will be initially supported is represented
below. It is possible that additional fields will be supported in the future.

```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.3",
  "version": <BOM revision number>,
  "components": [
    {
      "type": <component type, usually library>,
      "name": <package name>,
      "version": <package version>,
      "licenses": [<package license ID(s) in SPDX-format>],
      "purl": <package URL per github.com/package-url>,
    }
  ]
}
```


## Prior Art

[Paketo RFC#33](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0033-bill-of-materials.md)

[CNB RFC #95: SBOM](https://github.com/buildpacks/rfcs/blob/main/text/0095-sbom.md)

[CNB Run Image SBoM RFC (WIP)](https://github.com/aemengo/rfcs/blob/add-run-image-sbom/text/0000-run-image-sbom.md)

