# Ruby Paketo Buildpack Promotion

## Summary

A Ruby Buildpack has been created by contributors to the Paketo Project and currently resides in the [Paketo Community Github Org.](https://github.com/paketo-community/ruby). This RFC proposes the promotion of the Ruby Buildpack from a "Community" buildpack to an official Paketo Buildpack. 

## Motivation

The community Ruby Buildpack has reached an initial feature completion state and supports the most common Ruby app use cases. Ruby support in Paketo was intially requested by members of the CF community working on developing [CF for K8s](https://github.com/cloudfoundry/cf-for-k8s), and the resulting buildpack is actively used by components in CF for K8s as well as other community members. 

Ruby is one of the most popular programming languages so we'd like to promote it as an official Paketo project maintained Buildpack so that we can expose it to a much broader set of users (via the Paketo builders). 

## Detailed Explanation
The Ruby Buildpack is promoted to the `paketo-buildpacks` Github org. and considered an official language supported by the Paketo project. The Ruby Buildpack will be included in Paketo builders and promoted in website content.

The buildpack currently provides MRI (Matz Ruby Interpreter) and Bundler as dependency and supports the most common web servers (Puma, Unicorn, Thin, Passenger, Rackup) as well as support for non-web server use cases such as Rake tasks.

Upon promotion, future enhancements will be made from directly within the `paketo-buildpacks` org. 

## Rationale and Alternatives

N/A

## Implementation

The following repos will be moved from the `paketo-community` to `paketo-buildpacks` Github Org:
- [Language Family Ruby Buildpack](https://github.com/paketo-community/ruby)
- [MRI Buildpack](https://github.com/paketo-community/mri)
- [Bundler Buildpack](https://github.com/paketo-community/bundler)
- [Bundle Install Buildpack](https://github.com/paketo-community/bundle-install)
- [Puma Buildpack](https://github.com/paketo-community/puma/)
- [Unicorn Buildpack](https://github.com/paketo-community/unicorn/)
- [Thin Buildpack](https://github.com/paketo-community/thin/)
- [Passenger Buildpack](https://github.com/paketo-community/passenger/)
- [Rackup Buildpack](https://github.com/paketo-community/rackup/)
- [Rake Buildpack](https://github.com/paketo-community/rake)

**All** Ruby Buildpack IDs will be updated to `paketo-buildpacks/<RUNTIME>`

**All** Ruby Buildpack artifacts will be shipped to `gcr.io/paketo-buildpacks/<RUNTIME>`

The Ruby Buildpack will be added to Base & Full Paketo Builders as described in the [ordering RFC](https://github.com/paketo-buildpacks/builder/blob/main/rfcs/0001-buildpack-order.md)

Sample apps for common Ruby app configurations will be added to the [Paketo samples repo](https://github.com/paketo-buildpacks/samples)

Ruby logo will be added to the [Paketo website](https://github.com/paketo-buildpacks/samples)

## Prior Art

N/A

## Unresolved Questions and Bikeshedding

N/A