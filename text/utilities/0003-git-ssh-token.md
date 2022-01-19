# SSH Token Configuration in the Git Buildpack

## Summary

Add the ability to supply an SSH token to the Git buildpack that will be used
by `git` in order to allow later buildpacks to perform operations that require
`git` authentication.

## Motivation

There are some operations, such as obtaining private language modules, that
require `git` authentication during the build process. Currently there is now
way of authenticating as a user to enable these workflows. Adding this
functionality to the Git buildpack would open up a wider range of workflows
than adding the functionality on an individual buildpack basis and make the
ability to add SSH authentication to the project universally. 

## Implementation

For security purposes, the token cannot be provided through an environment
variable like most of our other buildpack configuration as this poses a risk of
exposure by view the build process in some form of CI. Because of this
restriction, an approach similar to the CA Certificates Buildpack will be used
where the token will be provided in a mounted volume through a service binding.
That token will then be used to change the global `git` config for that
container which will persist for the entirety of the build which the [CNB
specification](https://github.com/buildpacks/spec/blob/main/buildpack.md#requirements)
states must all happen in the same container for security purposes. The
following commands will be used to modify the global `git` config:
```bash
git config --global url."https://api:{{token}}@github.com/".insteadOf "https://github.com/"
git config --global url."https://ssh:{{token}}@github.com/".insteadOf "ssh://git@github.com/"
git config --global url."https://git:{{token}}@github.com/".insteadOf "git@github.com:"
```

## References

- [Guide to Non-Interactive Git Authentication](https://coolaj86.com/articles/vanilla-devops-git-credentials-cheatsheet/)
- [CA Certificates](https://github.com/paketo-buildpacks/ca-certificates)
