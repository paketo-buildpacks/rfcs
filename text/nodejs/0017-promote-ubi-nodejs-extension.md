# Promote the ubi-nodejs-extension to paketo-buildpacks

## Summary

Promote the the [ubi-nodejs-extension](https://github.com/paketo-community/ubi-nodejs-extension)
from paketo-community to packet-buildpacks.

## Motivation 

The ubi-nodejs-extension has been building and releases have been published regularly over the
last year. There are no outstanding major issues and we've not had to make any substantial
changes over the last few months and it seems like it's time to be promoted.

In addition, the extension mechanism is no longer experimental.

## Detalied Explanation

## Rational and Alternatives

UBI support was planned and agreed in this rfc -
[https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md?](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0056-ubi-based-stacks.md) 

Promotion of the ubi-nodejs-extension is a step towards completing this and the ubi-nodejs-extension
is ready and actively maintained with no major open issues and regular releases.

The alternative is to leave the ubi-nodejs-extension in paketo-community to bake for a while longer

## Implementation

* Move the packeto-community/ubi-nodejs-extension repo to `paketo-buildpacks/ubi-nodejs-extension`
* Fixup and changes needed in the automation scripts, etc.
* Update references in the paketo-buildpackes/nodejs meta buildpack to point to
  `paketo-buildpacks/ubi-nodejs-extension`. 

## Prior Art

## Unresolved Questions and Bikeshedding

N/A


