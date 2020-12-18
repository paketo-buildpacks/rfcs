# Default Values for Language Ecosystem Env Vars Set by Buildpacks

## Summary

{{A concise, one-paragraph description of the change.}}

## Motivation

{{Why are we doing this? What pain points does this resolve? What use cases
does it support? What is the expected outcome? Use real, concrete examples to
make your case!}}

Some Paketo buildpacks set environment variables used to configure language
ecosystem tooling. Often, buildpacks use the
[override](https://github.com/buildpacks/spec/blob/main/buildpack.md#override)
environment variable modification rule provided by the lifecycle. As a result,
buildpack users **cannot** themselves provide alternate values for these
environment variables at build or launch time (e.g. with `pack build app --env
VARIABLE=value`).


If buildpacks instead set language-ecosystem environment variables using the
[default](https://github.com/buildpacks/spec/blob/main/buildpack.md#default)
environment variable modification rule, buildpack users will consistently be
able to override these environment variables at build and/or launch to better
meet their needs.

Additionally, the each buildpack should check whether there is already a value
for the given environment variable available, and if there is, it should **set
that value as the default** for the remainder of the build and/or for launch.

### Example: `NODE_ENV`
#### Current Behaviour
The Node Engine CNB sets the `NODE_ENV`  environment variable during its [build
phase](https://github.com/paketo-buildpacks/node-engine/blob/b8169c8ed58a468e28c0ebafea7cfa528e8a3e69/build.go#L110).
It [uses the override
rule](https://github.com/paketo-buildpacks/node-engine/blob/b8169c8ed58a468e28c0ebafea7cfa528e8a3e69/environment.go#L35)
to set the value for build and launch. Node developers may want to set
`NODE_ENV` themselves to control build- and launch-time behaviour. For
instance, [`NODE_ENV` impacts which dependencies are installed by `npm
install`](https://docs.npmjs.com/cli/v6/commands/npm-install#description).

Currently, [Paketo Nodejs Buildpack users cannot force the buildpack to install
`devDependencies`](https://github.com/paketo-buildpacks/node-engine/issues/196)
because `NODE_ENV` is set to `"production"` by the Node Engine CNB.

#### Behaviour After Proposed Change
With the proposed change, a user could install `devDependencies` during their
build with:
```
pack build node-app --env NODE_ENV="development"
```

Notably, at launch time, `NODE_ENV` would also be set to `"development"`. To
change the launch-time value, the user could inject a new value at container
run time:
```
docker run node-app --env NODE_ENV="production"
```

Alternately, they could use the Environment Variables buildpack to bake a
different launch-time default into the image:
```
pack build node-app --env NODE_ENV="development" \
                    --env BPE_DEFAULT_NODE_ENV="production"
```
In this case, the build-time value of `NODE_ENV` is `"development"` and the
launch-time value would be `"production"`.


### Example: `BUNDLE_DISABLE_CHECKSUM_VALIDATION`
#### Current Behaviour
Currently, no buildpack interacts with the `BUNDLE_DISABLE_CHECKSUM_VALIDATION`
environment variable. However, it's a configuration option [respected by
`bundle`](https://bundler.io/v2.0/bundle_config.html#LIST-OF-AVAILABLE-KEYS). A
user can therefore configure their build with this option using:
```
pack build ruby-app --env BUNDLE_DISABLE_CHECKSUM_VALIDATION=true
```
which **will** successfully disable checksum validation during the build phase.
The environment variable will not be set at launch time.

#### Behaviour After Proposed Change
With the proposed change, users would be able to set the build-time value of
this environment variable exactly as before. The proposed change would **not**
set `BUNDLE_DISABLE_CHECKSUM_VALIDATION=true` at launch time, since no
buildpack directly manipulates this environment variable.

## Detailed Explanation

{{ Explain needed changes for each current buildpack that interacts with
environment variables. }}

{{Describe the expected changes in detail.}}

## Rationale and Alternatives

1. What the non-Java buildpacks do
2. what the Java buildpack does

{{Discuss 2-3 different alternative solutions that were considered. This is
required, even if it seems like a stretch. Then explain why this is the best
choice out of available ones.}}

## Implementation

{{Give a high-level overview of implementation requirements and concerns. Be
specific about areas of code that need to change, and what their potential
effects are. Discuss which repositories and sub-components will be affected,
and what its overall code effect might be.}}

{{THIS SECTION IS REQUIRED FOR RATIFICATION -- you can skip it if you don't
know the technical details when first submitting the proposal, but it must be
there before it's accepted.}}

## Prior Art

1. indication of how the non-java BPs do it
2. how the java bp does it
3. other buildpacks from other authors? what do they do?

{{This section is optional if there are no actual prior examples in other tools.}}

{{Discuss existing examples of this change in other tools, and how they've
addressed various concerns discussed above, and what the effect of those
decisions has been.}}

## Unresolved Questions and Bikeshedding

{{Write about any arbitrary decisions that need to be made (syntax, colors,
formatting, minor UX decisions), and any questions for the proposal that have
not been answered.}}

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
