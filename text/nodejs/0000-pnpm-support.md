# Support PNPM Package Manager in Node.js Language Family

## Summary

Add first-class `pnpm` support to the Paketo Node.js language family: a `pnpm` CLI buildpack, a `pnpm-install` buildpack, and a new order group in `paketo-buildpacks/nodejs` so apps using `pnpm-lock.yaml` build natively, the same way npm and yarn apps already do.

## Motivation

pnpm has become one of the default choices for JS projects — Vue, Vite, Svelte, and Nuxt all recommend or require it, mostly for its disk usage and monorepo handling. Paketo's Node.js family currently only understands npm and yarn, so anyone on pnpm has to work around it: `corepack`, custom scripts before the real build step, or giving up and switching package managers just to get a clean buildpack build. None of that should be necessary.

This has been asked for since 2022 in paketo-buildpacks/nodejs#594, with more reactions than most open issues in that repo get.

## Detailed Explanation

### Two new buildpacks

- **`pnpm`** resolves a pnpm version and puts the binary on `$PATH`. It doesn't gate on anything — detection always passes, and its only job is figuring out which version to hand off.
- **`pnpm-install`** does the actual `pnpm install`, and is where all of the interesting behavior lives (detection, caching, the pnpm-specific quirks below).

### Order group

The new `pnpm` group goes first in `paketo-buildpacks/nodejs`, ahead of `yarn` and `npm`. It mirrors the structure of the existing groups exactly — same optional utility buildpacks (`ca-certificates`, `watchexec`, `tini`, `cpython`), same tail (`node-run-script`, `node-start`, etc.). Nothing about the yarn or npm groups changes.

```toml
[[order]]
  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/watchexec"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/tini"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/cpython"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/node-engine"
  [[order.group]]
    id = "paketo-buildpacks/pnpm"
  [[order.group]]
    id = "paketo-buildpacks/pnpm-install"
  [[order.group]]
    id = "paketo-buildpacks/node-run-script"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/node-start"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/procfile"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/environment-variables"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/image-labels"
    optional = true
```

`pnpm-install` fails detection without a `pnpm-lock.yaml` and `package.json`, so an app without pnpm just falls through to the yarn group and then npm, exactly as it does today.

### Version resolution

`pnpm` picks a version in this order: `BP_PNPM_VERSION` env var, then `packageManager` in `package.json`, then `pnpm-lock.yaml`'s `lockfileVersion` (mapped to a major — lockfile 5 is pnpm 7, lockfile 6 is pnpm 8, lockfile N≥9 is pnpm N), then a default of the latest 9.x.

One wrinkle: this buildpack's own dependency metadata won't always have the exact patch a project pins (that metadata gets updated on its own cadence, pnpm ships patches often). If someone's `package.json` says `"packageManager": "pnpm@10.34.5"` and this buildpack only has `10.34.2` packaged, failing the build over that difference would be worse than just using it — so it falls back to the closest version in the same major and logs why:

```
Warning: requested pnpm@10.34.5 is not available in this buildpack's dependency
metadata; falling back to closest available version pnpm@10.34.2. Set
BP_PNPM_STRICT_VERSION_MATCH=true to fail the build instead of substituting a
version.
```

`BP_PNPM_STRICT_VERSION_MATCH=true` turns that off for anyone who'd rather know immediately. A bare major request like `BP_PNPM_VERSION=9` was never an exact pin to begin with, so it's unaffected either way.

### Why this needs a second buildpack to know about it

pnpm has enforced an exact match between its own version and `packageManager` since v9 — if they don't match, it just refuses to run (`ERR_PNPM_BAD_PM_VERSION`). So the substitution above, if it happens, would otherwise break the very next step. `pnpm` signals the mismatch to `pnpm-install` through a `PNPM_VERSION_MISMATCH` SharedEnv variable, and `pnpm-install` relaxes pnpm's own version check only when that's set:

- pnpm 9/10: `--config.package-manager-strict=false`
- pnpm 11+: `--config.pmOnFail=warn` (the older setting was removed outright in v11)

This is deliberately narrow — it only kicks in when a mismatch actually happened. The common case, where the version matches exactly, leaves pnpm's own guarantee untouched.

### Install behavior

`pnpm-install` runs `pnpm install --frozen-lockfile`. It checks `pnpm config get store-dir` first and adds `--offline` automatically if that directory already exists, so a pre-warmed store gives you a fully offline build with no extra config. `--prod` gets added for the launch layer whenever `NODE_ENV` isn't `development`.

Caching is two layers, `build-modules` and `launch-modules`, each keyed on a checksum of `pnpm-lock.yaml`, `package.json`, `pnpm config list` output, `NODE_ENV`, and the resolved Node.js version. That last one matters more than it sounds — without it, a cache hit could hand back `node_modules` built against a different Node ABI after a Node version bump, and any native dependency in there would just be silently stale until something crashes at launch.

`.npmrc` and `.pnpmrc` service bindings get symlinked into `$HOME`. Since pnpm v10+ only reads `.npmrc`, a binding that only provides `.pnpmrc` gets linked to both paths so it still works.

### pnpm 10+ blocks dependency build scripts by default

This one's a bigger deal than it sounds. Since pnpm v10, `preinstall`/`install`/`postinstall` scripts for dependencies don't run unless explicitly approved — meant to stop a compromised package from running arbitrary code on install. Approving them normally means `pnpm approve-builds`, an interactive prompt, which doesn't exist in a CNB build.

Left alone, this doesn't fail the build. `pnpm install --frozen-lockfile` just succeeds with the build script silently skipped, and anything that depends on it (a native compile step for `bcrypt`, `sharp`, `sqlite3`, whatever) is missing. The app builds fine and dies at launch instead, which is a much worse place to find out.

`pnpm-install` handles this by adding `--dangerously-allow-all-builds` automatically once it confirms (via `pnpm --version`) that the resolved pnpm is 10+ — the flag doesn't exist before that and pnpm hard-fails on any flag it doesn't recognize, so this is always version-checked, never assumed. `BP_PNPM_STRICT_BUILD_SCRIPTS=true` turns it off and leaves pnpm's default in place.

Defaulting to "on" instead of requiring opt-in follows the same shape as Paketo's own `ca-certificates` buildpack, which enables its runtime cert binding by default and expects an explicit opt-out rather than opt-in. The reasoning carries over here too: a CNB build is an isolated, ephemeral environment rebuilt from a known image every time, which isn't really the same trust boundary pnpm's default is protecting against. Flagged below for maintainer input since it's a real security-relevant default, not just an implementation detail.

## Drawbacks

- Two new repositories, two new build plan entries, one more thing to keep in sync with pnpm's release cadence — pnpm's own defaults have moved fast enough (three separate breaking-default changes across v9 through v11, detailed below) that this buildpack will need regular attention to not fall behind.
- The `PNPM_VERSION_MISMATCH` SharedEnv signal between `pnpm` and `pnpm-install` is a real exception to the usual build-plan-only communication between Paketo buildpacks, and needs sign-off as a pattern, not just as an implementation.
- Defaulting to `--dangerously-allow-all-builds` on pnpm 10+ is choosing a specific answer to a security tradeoff on behalf of every user of this buildpack. Reasonable people could pick the opposite default.

## Rationale and Alternatives

**Relying on `corepack` instead:** doesn't work for air-gapped builds, since corepack fetches the package manager binary on demand. A dedicated buildpack keeps things fully offline-capable.

**Pre-install scripts via `node-run-script`:** what people currently do, and it's boilerplate-heavy, inconsistent about caching, and a worse experience than a buildpack that just handles it.

**Relying on pnpm's own store / `side-effects-cache` instead of layer-based caching:** considered and rejected. pnpm's community has already run into `.pnpm-store` not reliably preserving compiled native binaries across separate cache steps (pnpm/pnpm discussion #3657). `side-effects-cache` specifically has caused real container build failures — native binaries resolving to paths that don't exist in a different container (pnpm/pnpm#3201), postinstall results silently reused for packages whose scripts should've re-run (pnpm/pnpm discussions#7993). The setting to control it has also moved between `.npmrc` and `pnpm-workspace.yaml` and had a version range where it silently didn't work at all (pnpm/pnpm#9394). Caching the final `node_modules` directly — what `npm-install`/`yarn-install` already do — sidesteps all of that.

## Known pnpm Behavior Changes Worth Tracking

pnpm's own defaults have shifted meaningfully across the version range this buildpack supports (0–12), independent of anything above. None of these need a fix in this RFC, but a reviewer should know about them:

- **`minimumReleaseAge` (pnpm 11+, default 1 day)**: pnpm 11 won't install a package version published less than 24 hours ago by default. This needs a registry round-trip, which is worth knowing about for the offline-install path above.
- **`blockExoticSubdeps` (pnpm 11+, default on)**: blocks transitive dependencies resolved from git URLs or direct tarball links. Only affects projects with that kind of dependency in their tree, and only transitively — direct dependencies are unaffected.
- **Node.js 22+ required (pnpm 11+)**: pnpm 11 simply won't run on an older Node.js. This buildpack doesn't currently cross-check the resolved Node.js version against the resolved pnpm version, so a project without a pinned `engines.node` could end up with an incompatible pair. `pnpm-install` does log a warning when it can (see below) but doesn't block the build.
- **`ERR_PNPM_UNEXPECTED_STORE`**: can show up if a persistent, externally-provided store (see "Offline Installation" above) was populated by a different pnpm major than the one currently resolved.
- **The build-scripts setting itself has moved before v11**: `allowBuilds` was introduced in pnpm 10.26, ahead of the v11 rename — so even within the 10.x line, the exact configuration surface for this has changed more than once. `--dangerously-allow-all-builds` as a CLI flag appears stable across that, but it's worth someone double-checking against a full pnpm 10.0 through 11.x version matrix before this ships, rather than trusting a major-version check alone.

## Implementation

- `paketo-buildpacks/pnpm` — new repo, Go, using `packit`.
- `paketo-buildpacks/pnpm-install` — new repo, Go, using `packit`.
- `paketo-buildpacks/nodejs` — `buildpack.toml` change only, adding the order group above.

## Prior Art

- RFC 0008: Modular Yarn Install
- RFC 0014: Support for Yarn Berry

## Unresolved Questions

- Whether `pnpm-workspace.yaml`-specific handling (beyond the existing `BP_NODE_PROJECT_PATH` project-path convention npm/yarn already use) is needed for proper workspace support, or whether pointing at a single project path is enough for a first version.
- Whether `pnpm` taking precedence over `yarn` when a project somehow has both a `pnpm-lock.yaml` and a `yarn.lock` is the right call — it mirrors how `yarn` already beats `npm` in the equivalent case, but three package managers is a new situation for this codebase.
- Whether defaulting to `--dangerously-allow-all-builds` on pnpm 10+ is the right default, or whether it should be opt-in instead — this is the one item in this RFC I'd most want explicit maintainer agreement on before merging, since it's a security posture decision, not just an engineering one.
- Whether the `PNPM_VERSION_MISMATCH` SharedEnv signal between the two buildpacks is an acceptable pattern, or whether this kind of cross-buildpack signal should go through the build plan instead.
