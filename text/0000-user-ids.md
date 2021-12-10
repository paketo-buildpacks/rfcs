# Secure runtime environments

## Summary

This RFC recommends that Paketo Buildpacks should in general strive to avoid making run-time modifications to the Buildpacks layers or the application directory by default. Instead, they should consider the output image to be read-only by default and explicitly set the parts that need to be writeable during runtime.


## Motivation

As of Buildpacks [RFC 0085](https://github.com/buildpacks/rfcs/blob/main/text/0085-run-uid.md) the Cloud Native Buildpacks project recommends that the run-time and build-time user ids be different. The motivation behind this RFC was to improve the security of output images and prevent arbitrary runtime modifications to built artifacts.

The run-time and build-time user can potentially share the same group id if they wish to make modifications to the output image during run-time, by changing the permissions of the files they wish to modify during run-time to be group writable during the build process. Ideally most buildpacks should use the temporary directories or other known scratch directories for ephemeral runtime files.

## Detailed Explanation

This RFC recommends that we identify buildpacks that making runtime modifications to the application directory or buildpack layers and modify them to instead use a temporary directory - or have them make these files group writable instead. All the current Paketo stacks' build-time and run-time users belong to a unique group so changing the file permissions to be group writable should have no additional security implications for users using the Paketo stacks.


## Rationale and Alternatives


The rationale behind this RFC is explained in the upstream RFC - [RFC 0085](https://github.com/buildpacks/rfcs/blob/main/text/0085-run-uid.md)

In the future we could also modify the Paketo stacks to have different run-time/build-time user ids once all the buildpacks follow this practice for a more secure experience.

## Implementation

At a high level this would involve the following - 

- Create base stacks equivalent to the current Paketo stacks but with different runtime user ids. Alternatively, we can also target the next Ubuntu/RHEL-UBI based Paketo stacks to contain a different build/runtime user id.
- Run a parallel test pipeline which is optional and allowed to fail for each buildpack. This pipeline should utilize this new builders to gather the level of compliance for the current set of buildpacks. These tests should also provide appropriate directories for writing ephemeral files during runtime such as `/tmp` or `/run`. We can also use docker to mimic read only directories per https://www.thorsten-hans.com/read-only-filesystems-in-docker-and-kubernetes/
- Track the compliance status and update buildpacks as necessary to comply with this RFC. The majority changes that would be needed would be for runtime executables/scripts provided by buildpacks such as `profile.d` or `exec.d` interfaces. Seperately we would also need to track configuration locations for configurations provided by buildpacks which lead to files being written on the root filesystem, such as log files etc. and configure them to write to ephemeral locations such as `/tmp` or the runtime user's home directory.
- We should create a utility buildpack that allows users to specific path patterns in `gitignore` format to make such directories group writable.
- Once all buildpacks comply, we can release the new set of builders/stacks with hardened security environments to Paketo users. - At some point in the future we can deprecate the current less-secure builders and stacks.
## Prior Art

- Most dockerfiles install build time dependencies as a different user than the final runtime user
- Platforms like OpenShift use a random uid but a common gid to limit the scope of runtime modifications and enhance security.

## Unresolved Questions and Bikeshedding

TBD
