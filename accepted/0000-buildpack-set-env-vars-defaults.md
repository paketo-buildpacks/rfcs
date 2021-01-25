# Default Behaviour for Buildpack-Set Language Ecosystem Environment Variables

## Summary

Paketo buildpacks sometimes use language ecosystem environment variables to
configure build- and launch time behaviour.  The environment variables' values
can come a) from user input at build/launch time or b) from buildpacks'
"opinions" about proper settings for the container build. If a user provides a
language ecosystem environment variable at build time **and** the buildpack
typically sets an opinionated build time value, the user's value should
override or have precedence over the buildpack-set value. Likewise if a user
provides a language ecosystem environment variable at launch time.

In addition, if a user provides a language-ecosystem environment variable at
build time, that value **should not** be "sticky" -- it should not influence
the launch time value of the environment variable. If a user wants to change
the launch time value of an environment variable, they should provide it at
launch time.

<!---
{{A concise, one-paragraph description of the change.}}
-->

## Motivation

Paketo strives to create buildpacks that help the majority of users (app
developers, app operators) containerize their apps with minimal
buildpack-specific configuration required. One way Paketo achieves this:
buildpacks often allow users to provide build-time environment variables that
are respected by language-ecosystem build tooling.

Currently, different buildpacks have different behaviour when it comes to
interacting with these language-ecosystem environment variables. The goal of
this RFC is to align the Paketo project on a single coherent approach to these
environment variables. The RFC will serve as a decision record for this
approach. The result will be a consistent and intuitive configuration UX for
buildpack users, regardless of the buildpack(s) they use.

<!---
{{Why are we doing this? What pain points does this resolve? What use cases
does it support? What is the expected outcome? Use real, concrete examples to
make your case!}}
-->

## Detailed Explanation

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

Buildpacks should not carry over build time values of language ecosystem
environment variables to launch time. Users can provide these at launch time,
or include them in the launch time image via the [Environment Variables
buildpack](https://github.com/paketo-buildpacks/environment-variables).

### Example: `NODE_ENV`
#### Current Behaviour
The Node Engine CNB sets the `NODE_ENV`  environment variable during its [build
phase](https://github.com/paketo-buildpacks/node-engine/blob/b8169c8ed58a468e28c0ebafea7cfa528e8a3e69/build.go#L110).
It [uses the override
rule](https://github.com/paketo-buildpacks/node-engine/blob/b8169c8ed58a468e28c0ebafea7cfa528e8a3e69/environment.go#L35)
to set the value for build and launch. Node developers may want to set
`NODE_ENV` themselves to control build- and launch time behaviour. For
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

At launch time, `NODE_ENV` is set to `"production"` by default.

To change the launch time value, the user can inject a new value at container
run time:
```
docker run node-app --env NODE_ENV="development"
```
At launch time, `NODE_ENV` is now set to `"development"`.

Alternately, they can use the Environment Variables buildpack to bake a
different launch time default into the image:
```
pack build node-app --env NODE_ENV="development" \
                    --env BPE_DEFAULT_NODE_ENV="development"
```
In this case, the build-time value of `NODE_ENV` is `"development"` and the
launch time default value is `"development"`.


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
set `BUNDLE_DISABLE_CHECKSUM_VALIDATION=true` at launch time.
To change the launch time value, the user could inject a new value at container
run time:
```
docker run ruby-app --env BUNDLE_DISABLE_CHECKSUM_VALIDATION=true
```

Alternately, they could use the Environment Variables buildpack to bake a
different launch time default into the image:
```
pack build node-app --env BUNDLE_DISABLE_CHECKSUM_VALIDATION=true \
                    --env BPE_DEFAULT_BUNDLE_DISABLE_CHECKSUM_VALIDATION=true
```
In this case, the build- and launch time values of
`BUNDLE_DISABLE_CHECKSUM_VALIDATION` is `true`.

### Example: `JAVA_TOOL_OPTIONS`
#### Current Behaviour
Currently, the `JAVA_TOOL_OPTIONS` environment variable is set at launch time
by various buildpacks including the Java [Debug
Buildpack](https://github.com/paketo-buildpacks/debug/blob/ebc132acf0ed8bd084839263d37a0a8c9846e41c/helper/debug.go#L59)
and the [JMX
Buildpack](https://github.com/paketo-buildpacks/jmx/blob/5d2c6097bc439a0717dbbda330bdee4a32db42d5/helper/jmx.go#L44).
Users can influence the values set by the buildpack by specifying the
[buildpack-specific environment variables (e.g.
`BPL_JVM_HEAD_ROOM`)](https://paketo.io/docs/buildpacks/language-family-buildpacks/java/#configuring-jvm-at-runtime)
at launch time. The buildpacks compute correct values to populate the
`JAVA_TOOL_OPTIONS` based on the values of the other environment variables and
certain launch time configuration (e.g.  memory available to the container at
run time).

If a user provides a value of `JAVA_TOOL_OPTIONS` at build time, its value will
be available to all of the buildpacks at build time, but the inputted value of
the environment variable **is not** added to the launch time environment.

If a user sets `JAVA_TOOL_OPTIONS` at launch time, the [user-provided flags are
appended to the buildpack-calculated
ones](https://paketo.io/docs/buildpacks/language-family-buildpacks/java/#configuring-jvm-at-runtime).

If both a user and buildpack set a flag, the user-provided value takes precedence.

#### Behaviour After Proposed Change
This RFC would not change the behaviour of any buildpacks with respect to this
environment variable.

<!---
{{Describe the expected changes in detail.}}
-->
## Rationale and Alternatives

1. Do not change the behaviour of any of the current buildpacks. Allow
buildpack authors to determine a convenient UX for the specific environment
variables they interact with.
  - Benefit: No technical changes required
  - Drawback: Inconsistent UX for environment variables across buildpacks.
2.  Persuade the the CNB project to adopt a specification for setting runtime
    env vars during build (something like the `environment-variables` buildpack
    but built directly into the `lifecycle`, enabling an improved UX).

<!---
{Add other alternatives}

{{Discuss 2-3 different alternative solutions that were considered. This is
required, even if it seems like a stretch. Then explain why this is the best
choice out of available ones.}}
-->

## Implementation

To implement this change, buildpacks that configure environment variables that
are recognized by language-ecosystem tooling should set the `env.Default`
option, not the `env.Override` option at both build and launch. This will allow
users to configure the values of these environment variables.

Buildpacks should not, in general, use the values of language ecosystem
environment variables at build time as their launch time values. These launch
time values should be set by users directly via the Environment Variables
buildpack or with `docker run --env NAME=value` or similar.

<!---
{{Give a high-level overview of implementation requirements and concerns. Be
specific about areas of code that need to change, and what their potential
effects are. Discuss which repositories and sub-components will be affected,
and what its overall code effect might be.}}

{{THIS SECTION IS REQUIRED FOR RATIFICATION; you can skip it if you don't
know the technical details when first submitting the proposal, but it must be
there before it's accepted.}}
-->

## Prior Art

1. Paketo Nodejs Buildpack: Buildpack-Set Environment Variables (
   [`NODE_ENV`](https://paketo.io/docs/buildpacks/language-family-buildpacks/nodejs/))
2. Paketo Java Buildpack: [Configuring the JVM at
   Runtime](https://paketo.io/docs/buildpacks/language-family-buildpacks/java/#configuring-jvm-at-runtimel)

<!---
{{This section is optional if there are no actual prior examples in other tools.}}

{{Discuss existing examples of this change in other tools, and how they've
addressed various concerns discussed above, and what the effect of those
decisions has been.}}
-->

## Unresolved Questions and Bikeshedding

<!---
{{Write about any arbitrary decisions that need to be made (syntax, colors,
formatting, minor UX decisions), and any questions for the proposal that have
not been answered.}}

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
-->
