# Chmod Buildpack

## Important warning about this buildpack RFC

This buildpack could be harmful to your application if you don't use it carefully. By (un)doing file permissions, the application could behave unexpectedly in production for example.

## Summary

A chmod buildpack that allows users to change directories and files (produced at buildtime) UNIX permissions.

This buildpack would be configured to run last, so that it would be able to change any directories and files produced by previous buildpacks.

## Motivation

Buildpacks and Builders rely on Stacks.

Stacks define build time and runtime base images.

Some stacks do not use the same user / UID between build and run images, [for security reasons](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0045-user-ids.md), since a runtime user should just be able to run a process; not create directories nor install packages.

Unfortunately, some applications, like `dist-zip` archives, do need to create directories and files: they run setup scripts during runtime that fail because they can't write folders nor files, since they were run with a runtime user, who can be restricted with some Stacks. 

Similarly, some scripts that need to be run at runtime are only executable by the build time user, and would need to be executable by the runtime user.

## Detailed Explanation

N/A

## Rationale and Alternatives

We have considered solving the issue at different levels:

* At the stack level: reverting to former stacks that define the same user at build time and runtime.

After all, previous stacks like Ubuntu Bionic did not differentiate the runtime user from the build time user, both being named `cnb` with the UID 1000

We began noticing this issue with the latter stacks (some based on Ubuntu Jammy) that guarantee [a more secure environment](https://github.com/buildpacks/rfcs/blob/main/text/0085-run-uid.md) by having the build time user set to UID 1002, and runtime user set to 1000 at runtime.

* At the buildpack level: [implementing special flags in some buildpacks](https://github.com/paketo-buildpacks/dist-zip/pull/174) that would allow users of those buildpacks to make some folders group writable

But then, we discovered that it was not enough, some other flag would need to be implemented to let the build time user run a different set of scripts; and of course, we would need to replicate this behavior in several other buildpacks packaging applications that set themselves up at runtime.

Allowing the user to keep on using the same secure Stacks, and unmodified buildpacks, using a chmod buildpack at the end of their build seems like the best solution

## Implementation

The chmod buildpack would be added last to builders and would be activated if a specific flag is set.

Two flags, or environment variables, are suggested for configuring the `chmod` buildpack.

1. An environment variable named `BP_CHMOD_MAPPING` would be configured with a comma-separated map of folders and their desired owner and permissions.

For example:

`pack build -e BP_CHMOD_MAPPING="/workspace:0750:r,/workspace/bin:0755" myimage`

would activate the chmod buildpack and 

* make it change recursively the `/workspace` folder of the runtime image to have permissions `0750`
* make it change non-recursively the `/workspace/bin` folder of the runtime image to have permissions `0775` (making all these folder files executable)

2. An environment variable named `BP_CHMOD_MAPPING_FILE` would be configured with the location of a file defining the mapping (convenient for users configuring numerous mappings)

For example, the combination of:

`pack build -e BP_CHMOD_MAPPING_FILE=chmod-mappings.txt myimage`

and:

`chmod-mappings.txt`
```text
/workspace:0750:r
/workspace/bin:0755
```

would have the same effect as the previous example using `BP_CHMOD_MAPPING`. 

You will notice that there is no default file that this buildpack will auto-detect; it is to remain as safe as possible.

If both `BP_CHMOD_MAPPING` and `BP_CHMOD_MAPPING_FILE` are applied, then `BP_CHMOD_MAPPING` is applied first, then the mappings in the file are applied in order from the top to the bottom of the file.
## Prior Art

There exists a proof of concept [`chmod-buildpack`](https://github.com/anthonydahanne/chmod-buildpack/) available online.

## Unresolved Questions and Bikeshedding

N/A
