# RFC 000XX - Generate Reproducible SPDX SBOMs

## Summary

Currently, several Paketo buildpacks generate SPDX SBOMs using Syft. The
resulting SBOMs are not reproducible because they contain fields that are
intentionally unique for each time an SPDX document is generated. Since the
Cloud Native Buildpacks lifecycle embeds buildpack-generated SBOMs inside the
app images they build, Paketo buildpacks that generate SPDX SBOMs produce
irreproducible images. This violates a core value proposition of Cloud Native
Buildpacks. To continue generating SPDX SBOMs while maintaining build
reproducibility, Paketo buildpacks should replace the irreproducible data in
Syft-generated SPDX SBOMs with reproducible analogues. 

## Motivation
As described in [the reproducibility
amendment](https://github.com/paketo-buildpacks/rfcs/pull/220) to [RFC
0038](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0038-cdx-syft-sbom.md),
when buildpacks generate SBOMs that are irreproducible, they compromise overall
build reproducibility, since SBOM documents are included in the image in their
own layer. Build reproducibility is an [advertised
feature](https://buildpacks.io/docs/features/reproducibility/) of Cloud Native
Buildpacks, and we shouldn't force users to choose between SBOMs and
reproducibility.

Many Paketo buildpacks (e.g. Go, Node.js, Python) generate SBOMs in three
formats: Syft, CycloneDX, and SPDX. Syft SBOMs are (for now) entirely
reproducible. CycloneDX SBOMs contain optional fields that are not reproducible
(see [RFC 00038
Amendment](https://github.com/paketo-buildpacks/rfcs/pull/220)). On the other
hand, the [SPDX SBOM specification](https://spdx.github.io/spdx-spe) requires
two fields with data that are intentionally irreproducible:
- [`documentNamespace`](https://spdx.github.io/spdx-spec/document-creation-information/#65-spdx-document-namespace-field)
  (required), which "shall be unique for the SPDX document including the
  specific version of the SPDX document."
- [`created`](https://spdx.github.io/spdx-spec/document-creation-information/#69-created-field)
  (required), which is a timestamp used to "[i]dentify when the SPDX document
  was originally created".

Since SPDX is an
[established](https://www.linuxfoundation.org/blog/spdx-its-already-in-use-for-global-software-bill-of-materials-sbom-and-supply-chain-security/)
open standard for SBOM, we believe that it's valuable for Paketo's buildpacks
to continue generating spec-compliant SPDX SBOMs. But we must decide how to
fill the `documentNamespace` and `created` fields of the SBOM in a reproducible
way so users can get the benefits of SPDX _and_ buildpack build
reproducibility.

## Detailed Explanation

Currently, Paketo uses `anchore/syft`'s implementation of a SPDX v2.2 SBOM
generator. Syft combines the type of scanned resource (e.g. directory, file,
OCI image) with the resource name and a pseudo-randomly generated UUID to
populate the `documentNamespace` field of the SBOM. For instance, Syft outputs
```
"documentNamespace": "https://anchore.com/syft/dir/workspace-eeb24bd3-d91a-469c-8ce5-c8ef19347a70"
```
as the SPDX `documentNamespace` when scanning `/workspace` during a buildpack build. (See
the complete
[implementation](https://github.com/anchore/syft/blob/64b4852c2a197b639fcfc311685c6f48abaa9085/internal/formats/spdx22json/to_format_model.go)
of the transformation between Syft's data model and the SPDX specification
for more detail.) To populate the `created` field, [Syft gets the current
time](https://github.com/anchore/syft/blob/64b4852c2a197b639fcfc311685c6f48abaa9085/internal/formats/spdx22json/to_format_model.go#L32)
when the SBOM is encoded as SPDX JSON.

To preserve build reproducibility while generating SPDX SBOMs, Paketo must
replace the content in these two fields with reproducible data.

We should use a fixed timestamp to replace the variable timestamp that Syft embeds in the SPDX SBOM. Canonically, it's
appropriate to use the value of the
[`$SOURCE_DATE_EPOCH`](https://reproducible-builds.org/docs/source-date-epoch/)
environment variable. If this is unset, it's reasonable to pick our own fixed
default.

We should replace the irreproducible UUID that Syft includes in its SPDX
`documentNamespace` with a UUID that is reproducible. We can generate a name-based UUID according
to the [RFC4122 UUID Specification](https://datatracker.ietf.org/doc/html/rfc4122). In the specification, UUID versions
3 and 5 are name-based, meaning that "UUIDs generated at different times from the same name in the
same namespace MUST be equal." (See [the RFC](https://datatracker.ietf.org/doc/html/rfc4122#section-4.3)). In this case,
"name" is some identifier that is unique within the "namespace" in which it'll
be used. The RFC recommends that version 5 (which uses a SHA1 hash algorithm) is preferred. For our purposes, the "name"
is some representation of the contents of the SBOM. See the Implementation section for further details.

## Rationale and Alternatives

### Alternative: Stop Generating SPDX SBOMs
Technically, [RFC
0038](https://github.com/paketo-buildpacks/rfcs/blob/0818eeba4d4e91a05a39456a884a022b94a30bfd/text/0038-cdx-syft-sbom.md)
does not mandate that Paketo buildpacks generate SPDX SBOMs. The simplest
implementation option is to stop supporting SPDX SBOMs. However, SPDX is a
widely-used SBOM format and it's difficult to assess whether users are relying
on it. To remove SPDX support represents a breaking change across all non-Java
Paketo buildpacks. In the long term, the Cloud Native Buildpacks (CNB) project
may develop a way for buildpacks to provide SBOMs _without_ embedding them
within app images. If/when this happens, irreproducible SPDX SBOMs aren't a
problem. Paketo would be in a position to re-add SPDX after having already
dropped support. This turbulence inconveniences Paketo users who rely on SPDX
SBOMs. It's better to find a way to support reproducible SPDX SBOMs that can be
easily rolled back once SBOMs are no longer embedded in app images.

### Alternative: Maintain our own SPDX SBOM Format
Rather than manipulate Syft's SPDX encoded output after it's generated, we
can maintain our own implementation of the SPDX encoding. In particular, we can
write our own version of the
[`toFormatModel()`](https://github.com/anchore/syft/blob/64b4852c2a197b639fcfc311685c6f48abaa9085/internal/formats/spdx22json/to_format_model.go)
function, which transforms Syft's SBOM data structures into SPDX
representations. This would allow us to set custom values for the
`CreationInfo.Created` and `DocumentNamespace` fields on the `model.Document`
struct that the function returns as output. There are significant disadvantages
to maintaining our own SPDX SBOM encoding implementation. While there are
relatively few differences between Syft's implementation and our required
implementation, since Syft's implementation is inside an internal package, we
would need to copy and paste much of their implementation into our own. We
already do this for CycloneDX v1.3 and Syft v2 and v3.0.1. Adding those
implementations took significant engineering effort and created a large risk of
technical debt within `packit`. We become responsible for maintaining
compatibility between Syft's rapidly evolving SBOM data output and our
`toFormatModel()` implementations that convert the output into our SBOM
formats. I am reluctant to add yet another hand-rolled SBOM implementation to
our collection, especially when our version would be identical to theirs, but
for two fields. Syft maintainers had previously mentioned an interest in
exposing more SBOM-encoding APIs, but they haven't yet done this.

### Alternative: Contribute Reproducible SPDX SBOMs Upstream
We could attempt to contribute a variant of the SPDX SBOM format upstream that
produces reproducible documents. Once this reproducible-SPDX version is
available, we could consume it in the buildpacks. While Syft maintainers have
indicated that SBOM reproducibility [is a value for
them](https://github.com/anchore/syft/issues/1100#issuecomment-1183314044),
they already offer the feature within their Syft format. Moreover, they may be
hesitant to take on maintenance of another SBOM format with only one consumer
expressing interest. This option is not mutually exclusive with the main
proposal. While the main proposal is a short-term fix, contributing a
reproducible SPDX SBOM format could be a long-term solution.


## Implementation

To make the values stored in the `created` and `documentNamespace`  fields
reproducible, we can make a modification in `packit`'s
[`sbom.FormattedReader.Read()`](https://github.com/paketo-buildpacks/packit/blob/429f8e4370b9579e1c3340ede29a82f58152136d/sbom/formatted_reader.go#L41)
method that modifies the SPDX JSON outputted by `syft.Encode()`. After
`syft.Encode()` generates a SPDX JSON representation of the SBOM stored in a
reader, we can replace the contents of the two irreproducible fields with
reproducible data values. The Java buildpacks currently use a similar approach
– editing SBOM JSON after it's generated  – to achieve SBOM reproducibility for
CycloneDX SBOMs.

The value of `created` should be replaced with a default timestamp; if
[`$SOURCE_DATE_EPOCH`](https://reproducible-builds.org/docs/source-date-epoch/)
is set in the build environment, that time value should be used. If not, the
zero-value time in Golang should be used.

To produce a value for `documentNamespace` that (somewhat) uniquely identifies
a given SBOM document, we should generate a [Version 5 SHA1
UUID](https://go-recipes.dev/how-to-generate-uuids-with-go-be3988e771a6) based
on the hash of the struct stored in the `FormattedReader`'s `sbom` field. We should
replace the Syft-generated UUID with our reproducible one.
[`mitchellh/hashstructure`](https://github.com/mitchellh/hashstructure) is one
Golang implementation capable of hashing Golang structs. There are likely others.
Whichever we choose, it must be capable of deterministically hashing maps,
since Syft's SBOM representation contains several maps. By constructing a UUID
from the reproducible struct hash, and the `documentNamespace` from that UUID,
we'll produce a `documentNamespace` that is unique to the generated SBOM data
while also being reproducible. If elements like the list
of detected artifacts, the Syft version used to generate the data, or the
resource that's being scanned change, the resulting struct hash and UUID will
change.  To correctly use the Version 5 SHA1 UUID format, we will need to
create a [UUID
namespace](https://datatracker.ietf.org/doc/html/rfc4122#section-4.3) for
Paketo SBOM UUIDs.

Overall the value of `documentNamespace` should be transformed from:
```
"https://anchore.com/syft/dir/workspace-eeb24bd3-d91a-469c-8ce5-c8ef19347a70"
```
into
```
"https://paketo.io/packit/dir/workspace-75f2a2a1-b450-47cc-88ee-7b264bf37e85"
```

Note:
- The domain has been changed from `anchore.com` to `paketo.io` to reflect that
  we're generating the URI.
- `syft` has been replaced with `packit` to indicate what tool is generating
  the URI.
- The `/dir/workspace-` part of the path, which encodes the scanned resource
  type and basename of the scanned resource, is unchanged.
- The UUID suffix has been replaced; the new UUID is reproducible.

## Prior Art

- The Java buildpacks use Syft to generate SBOMs in CycloneDX JSON format, then
  strip out fields that are irreproducible.
- See https://github.com/paketo-buildpacks/packit/compare/reproducible-spdx for a
  spike demonstrating SBOM struct hashing. Use this version of `packit` within
  a buildpack to see the buildpack produce reproducible SPDX SBOMs.

## Unresolved Questions and Bikeshedding

- What should the version 5 UUID of the SBOM be based on? The only data
  currently available to `Read()` is the contents of the SBOM itself.
- Is hashing the SBOM struct actually reproducible? If it's not, this proposal doesn't solve our problem.

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
