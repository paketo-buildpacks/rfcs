# Credential Configuration in the Git Buildpack

## Summary

Add the ability to supply credentials to the Git buildpack that will be used by
`git` in order to allow later buildpacks to perform operations that require
`git` authentication.

## Motivation

There are some operations, such as obtaining private language modules, that
require `git` authentication during the build process. Currently there is now
way of authenticating as a user to enable these workflows. Adding this
functionality to the Git buildpack would open up a wider range of workflows
than adding the functionality on an individual buildpack basis and make the
ability to add credentials to the project universally.

## Implementation

For security purposes, the credentials cannot be provided through an
environment variable like most of our other buildpack configuration as this
poses a risk of exposure by view the build process in some form of CI. Because
of this restriction, an approach similar to the CA Certificates Buildpack will
be used where the credentials will be provided in a mounted volume through a
service binding. Those credentials will then be used to change the global `git`
config for that container which will persist for the entirety of the build
which the [CNB specification](https://github.com/buildpacks/spec/blob/main/buildpack.md#requirements)
states must all happen in the same container for security purposes.

The service binding structure will be as follows:
- `type`: `git-credentials`
- `context` (optional): The context is an optional pattern as defined by
  [`git`](https://git-scm.com/docs/gitcredentials#_credential_contexts). If a
  context is not provided then the credentials given in the binding will be the
  default credentials the `git` uses when authenticating. A given context can
  only be used once for any group of bindings, if a context is given by two
  separate bindings the build will fail.
- `credentials`: The credentials file should have the following format to
  conform with the [`git` credential structure](https://git-scm.com/docs/git-credential#IOFMT).
```
username=some-username
password=some-password/token
```

For every service binding the following `git` command will be run:
```shell
git config --global credential.{{context.}}helper "!cat path/to/binding/credentials"
```
This command will add the following to the global `git` config:
```shell
[credential "{{context}}"]
	helper = "!cat path/to/binding/credentials"
```

## References

- [Guide to Non-Interactive Git Authentication](https://coolaj86.com/articles/vanilla-devops-git-credentials-cheatsheet/)
- [CA Certificates](https://github.com/paketo-buildpacks/ca-certificates)
- [Custom Credential Helper](https://git-scm.com/docs/gitcredentials#_custom_helpers)
