# Update Hash Field in Bill of Materials

## Summary

Currently, the only hashing algorithm that we support in the BOM (bill of
materials) is `SHA256`, as the only checksum fields are explicitly named
`sha256`. This shoehorns the hash algorithm to `SHA256` and alienates any hashes
we can collect in other formats. This RFC proposes that the Paketo BOM supports
hashes in any algorithm.

## Motivation

In the original BOM RFC it was proposed to just have fields named `sha256` as
that was the only hashing algorithm used by dependencies hosted by Paketo.
However, in the pursuit of enhancing our BOM by adding information about things
such as node module information, we have started to use third party tools to
help generate the BOM. These third party tools return industry-standard BOM
formats that include a wide and varying array of hashes using varying hashing
algorithms. This has led us to conclude that our BOM specification needs to
update to be inclusive of a wide range of hashing algorithms to people that are
not hosting the packages they use and the metadata attached.

## Implementation

We propose the following change to the BOM schema:
```
[[bom]]
name = "<dependency name>"

[bom.metadata]
  arch = "<compatible processor architecture>"
  cpe = "<version-specific common platform enumeration>"
  deprecation-date = "<dependency EOS date formatted in using RFC 3339>"
  licenses = [<dependency license IDs(s) in SPDX Format>]
  purl = "<package URL per github.com/package-url>"
  summary = "<package summary>"
  uri = "<compiled dependency URI>"
  version = "<dependency version>"

[bom.metadata.checksum]
  algorithm = "<hashing algorithm>"
  hash = "<dependency artifact hash from URI made using the specified algorithm>"

[bom.metadata.source]
  name = "<dependency source name>"
  upstream-version = "<dependency source upstream version>"
  uri = "<dependency source URI>"
  version = "<dependency source version>"

[bom.metadata.source.checksum]
  algorithm = "<hashing algorithm>"
  hash = "<dependency source artifact hash from source URI made using the specified algorithm>"
```

This style closely reflects what both
[Cyclonedx](https://cyclonedx.org/docs/1.2/#type_hashType) and
[SPDX](https://github.com/spdx/spdx-spec/blob/development/v2.2.1/schemas/spdx-schema.json)
are doing in their representation of checksums.

## Rationale and Alternatives

* We could instead just replace the `sha256` fields with a `checksum` field and
  express the hash as `hash:algorithm`
* Don't use a new table but instead just add `hash` and `algorithm` fields

## Prior Art
* [Cyclonedx](https://cyclonedx.org/docs/1.2/#type_hashType)
* [SPDX](https://github.com/spdx/spdx-spec/blob/development/v2.2.1/schemas/spdx-schema.json)

## Unresolved Questions and Bikeshedding

* Field names and structure cause alway be bikeshed
