# Utility Buildpacks Team

## Summary

A team should be made that would be in charge in maintaining all of the so
called "utility" buildpacks, which is to say buildpacks that have cross
cutting, language agnostic usage.

## Motivation

Currently, there is no body that exists for buildpacks that do have large cross
cutting usage, which has led to these buildpacks being in many disparate
groups. There are several reasons why consolidating these buildpacks into one
group makes sense.
* Having the buildpacks in a seperate group will make it more evident that they
  are langugae agnostic.
* Having a separate maintainer group will hopefully encourage input from a
  wider range of user to make contributions.
* Having a separate maintainer group will make it more evident where new cross
  cutting buildpacks (take the git buildpack as an example) should be added.


## Rationale and Alternatives

* We do not create a new maintainer group and just leave the buildpacks in
  their existing teams.

## Implementation

A new team called `Utility` should be formed and the following buildpacks
should fall under that teams umbrella:
* Procfile
* CA Certificates
* Environment Variables
* Image Labels
* Build Plan

The current maintainers and contributors of those buildpacks should become
maintainers and contributors on the new `Utility` team in order to maintain
continuity and avoid having to cast for a whole new set of maintainers.

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
