# Modifications to Stack Software Bill of Materials Formats

## Summary

This RFC serves as an addendum to [Paketo RFC #0033](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0033-bill-of-materials.md).
Paketo Stack run images will contain a Software Bill of Materials (SBOM),
available in either CycloneDX or Syft JSON formats. It will be located in a layer at
`/cnb/sbom/bom.<cdx OR syft>.json` in accordance with the associated Cloud Native
Buildpacks specification.

## Motivation

Per [RFC #0033](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0033-bill-of-materials.md),
we defined a strategy for providing an SBOM for Paketo Buildpacks and Stacks.
The recent introduction of a Syft buildpack provides a mechanism for generating
BOM metadata in a plethora of formats, which can be used for scanning. This
addendum also keeps Paketo SBOM standards up-to-date with the upstream Cloud
Native Buildpacks project specification. Supporting these formats will make the
BOM more consumable for users than providing the SBOM in other formats.

## Detailed Explanation

The SBOM associated with Stack run images will now be available in either CycloneDX or
Syft formats. Per the CNB specification, the generated SBOM will be available at
`/cnb/sbom/bom.<ext>.json`, where `<ext>` will be `cdx` for CycloneDX documents and
`syft` for Syft documents. Then, the associated layer digest will be surfaced as a
`LABEL` on run image metadata under the `io.buildpacks.base.sbom` key.

### Overall Schema
The SBOM for each entry will correspond to an OS-level package provided by the
stack. The minimal set of fields we should provide for the `syft`-formatted SBOM
should conform to [Syft JSON Schema version
1.1.0](https://raw.githubusercontent.com/anchore/syft/main/schema/json/schema-1.1.0.json) and above:
```
{
 "artifacts": [
  {
   "id": "",
   "name": <package name>,
   "version": <package version>,
   "licenses": [<package license ID(s) in SPDX-format>],
   "cpes": [<version-specific common platform enumerations>],
   "purl": <package URL per github.com/package-url>,
  }
 ],
  "descriptor": {
  "name": "syft",
  "version": <Syft tool version>,
 },
 "schema": {
  "version": "1.1.0",
  "url": "https://raw.githubusercontent.com/anchore/syft/main/schema/json/schema-1.1.0.json"
 }
}
```

The minimal set of fields we should provide for the `cyclonedx`-formatted SBOM
should confirm to [CycloneDX schema version
1.2](https://github.com/CycloneDX/specification/blob/master/schema/bom-1.2.schema.json)
and above:
```
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.2",
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
Note that the CycloneDX schema does not include a `cpe` field, since the
CycloneDX project has deprecated its use.


## Rationale and Alternatives
- Support only one format

## Prior Art
- [CNB RFC: Add run image SBOM](https://github.com/buildpacks/rfcs/pull/186) 
- [RFC #0033: Implement a Bill of Materials Across Paketo](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0033-bill-of-materials.md)
- [WIP RFC: Proposes to add a new utilities buildpack for Syft](https://github.com/paketo-buildpacks/rfcs/pull/124)

## Unresolved Questions and Bikeshedding
- Is it acceptable that to support some fields (CPEs) in one format and not the other?
