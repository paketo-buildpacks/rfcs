# Paketo Community Go HTTP Function Buildpack.

## Summary

A Go buildpack that wraps an `http.HandlerFunc` in appropriate scaffolding to serve HTTP, and composes nicely with the existing `go-build` buildpacks.


## Motivation

A number of downstream projects have started to adopt Buildpacks as a mechanism for upleveling "app" (http server) abstractions into "function" abstractions (a la FaaS / lambda).

While probably the least interesting of the higher-level function signatures that folks target, many offerings surface the ability to wrap this as the lowest level "function" abstraction:

```
package fn

import "net/http"

func Handler(w http.ResponseWriter, r *http.Request) {
     fmt.Fprintf(w, "Hello World, %#v", r)
}
```

For the most naive HTTP servers, this doesn't reduce boilerplate much, but once applications start needing to integrate into more complex lifecycles (like the K8s SIGTERM/SIGKILL lifecycle) then the boilerplate reduction becomes quite significant, and shields the user from the the complexity of implementing this properly.


It is also notable that this "trivial" function signature example is a sort of canary, which will help us assess the readiness of downstream buildpacks for "function" style development, and act as a blueprint for future function buildpacks.


## Detailed Explanation

The intention here is to build a wholly separate buildpack based on https://github.com/mattmoor/http-go-fn which will eventually compose with the existing `go` Order like this: https://github.com/mattmoor/cloudevents-go-fn/blob/2e23ad960875b9b1c3633c041ed3011cefd9f6e2/buildpacks/order/buildpack.toml#L24-L27

The PoC leverages golang utilities to analyze the signature structure of target methods, so the idea is that `bin/detect` would keep this function from kicking in unless it's what the user desired.  This also ultimately will allow us to compose with other types of function signatures (e.g. in the above example a cloudevents signature).


## Rationale and Alternatives

There are a few other alternatives in the wild.

* The [Google buildpacks](https://github.com/GoogleCloudPlatform/buildpacks) essentially have a single monolith buildpack for all function signatures, and require `GOOGLE_FUNCTION_TARGET` to be set to activate the function capabilities.  One of the goals of this work would be to avoid that through more sophistication during detection.
* The [Boson](https://github.com/boson-project/buildpacks) (Openshift) builders bundle a very focused order, and rely much less on sophisticated detection.


## Implementation

My proposal would be to start from the `http-go-fn` repo above under `paketo-community`, and start to migrate it over to the Paketo-style of buildpacks (incl. inlining @vaikas signature detection magic so the repository is self-contained).

Once the PoC is cleaned up to meets the broader Paketo standards, I'd propose transfering to `paketo/` and including this as an optional phase of the `go` buildpack.

The `paketo-buildpacks/samples` will also be extended to include HTTP function examples.


## Prior Art

See alternatives, several of these were used to illustrate them.


## Unresolved Questions and Bikeshedding

Repository naming conventions assuming:
1. Over time this will expand to additional languages,
2. Over time this might expand to additional signatures.

Should an overarching initiative around "functions" in Paketo have some sort of better organization / coordination?
