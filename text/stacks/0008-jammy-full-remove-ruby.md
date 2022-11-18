# Remove Ruby from the Jammy Full Stack

## Summary

The Jammy Full stack should not install the `ruby` package.

## Motivation

The `ruby` (Ruby 3.0) package will reach the end of its support period (March
2024) before Jammy does (April 2027). This means that for a large portion of
the support period for the Jammy Full stack, it will contain an unsupported
Ruby interpreter.

Additionally, removing the `ruby` package will have little impact on existing
Jammy Full stack users since they will be able to still get a Ruby interpreter
through the `mri` buildpack or by employing a stack extension to install the
`ruby` package.

Finally, the existence of the `ruby` package in the stack is a relic of its
ancestry having been developed from the Cloud Foundry `cflinuxfs*` line of stack
images. In those stacks, the `ruby` package was required because some number of
buildpacks were written in Ruby and required an interpreter on the stack to
run. Given that Paketo does not have any buildpacks written in Ruby, the
original rationale for including the `ruby` package is gone.

## Detailed Explanation

Removing the `ruby` package from both the build and run image definitions in
the `stack.toml` file will result in an image that no longer includes that
package.

## Rationale and Alternatives

## Implementation

Remove the `ruby` package from the build and run package lists in the
`stack.toml` file.

## Prior Art

None

## Unresolved Questions and Bikeshedding

None
