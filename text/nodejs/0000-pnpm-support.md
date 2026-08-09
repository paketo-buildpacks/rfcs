# Support PNPM Package Manager in Node.js Language Family

## Summary

This RFC proposes adding first-class support for the `pnpm` package manager in the Paketo Node.js language family. This includes introducing a `pnpm` CLI dependency buildpack and a `pnpm-install` buildpack to manage application dependencies using `pnpm-lock.yaml`.

## Motivation

`pnpm` has seen widespread adoption across the JavaScript ecosystem due to its performance, disk space efficiency via content-addressable storage, and robust monorepo/workspace support. Major frameworks and open-source projects (such as Vue.js, Vite, Svelte, and Nuxt) now officially recommend or exclusively use `pnpm`.

Currently, the Paketo Node.js language family natively supports `npm` and `yarn`. Adding native support for `pnpm` will allow developers and organizations using `pnpm` to build container images out-of-the-box without relying on custom workarounds or pre-install scripts.

## Detailed Explanation

### Architecture & Buildpack Composition

Following the modular Paketo Node.js architecture (as defined in RFC 0001 and RFC 0008), we propose adding two new implementation buildpacks:

1. **`pnpm`**: Resolves the target `pnpm` version, downloads and installs the `pnpm` CLI package into a layer, and adds it to `$PATH`.
2. **`pnpm-install`**: Handles dependency installation by executing `pnpm install` and managing `node_modules`.

### Buildpack Order Grouping & Detection Precedence

In the composite `nodejs` meta-buildpack (`paketo-buildpacks/nodejs`), a new order group is added as the **first** order group — ahead of both the existing `yarn` and `npm` order groups.

Detection precedence between package managers is enforced at the `pnpm-install` and `npm-install` level, not by the `pnpm` CLI buildpack itself (see "Detection Logic" below). Because `npm-install` detection succeeds on any project containing a `package.json` file (acting as the default fallback for Node.js applications), placing the `pnpm` order group first ensures that the presence of `pnpm-lock.yaml` will correctly select the `pnpm` buildpacks over `yarn`/`npm`, while apps without a `pnpm-lock.yaml` fall through to `yarn`, then `npm`, exactly as they do today. The existing `yarn` and `npm` order groups, and their internal detection logic, remain completely untouched.

The updated order groups in `paketo-buildpacks/nodejs` are structured as follows (matching the existing group composition, including the optional `ca-certificates`, `watchexec`, `tini`, and `cpython` utility buildpacks already present in every group today):

```toml
# 1. PNPM Order Group (New)
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

# 2. Yarn Order Group (Existing, unchanged)
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
    id = "paketo-buildpacks/yarn"
  [[order.group]]
    id = "paketo-buildpacks/yarn-install"
  [[order.group]]
    id = "paketo-buildpacks/node-run-script"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/node-start"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/yarn-start"
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

# 3. NPM Order Group (Existing Fallback, unchanged)
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
    id = "paketo-buildpacks/npm-install"
  [[order.group]]
    id = "paketo-buildpacks/node-run-script"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/node-start"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/npm-start"
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

# 4. No-Package-Manager Fallback Order Group (Existing, unchanged)
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
    id = "paketo-buildpacks/node-engine"
  [[order.group]]
    id = "paketo-buildpacks/node-start"
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

### Detection Logic & Build Plan Contracts

1. **`pnpm` CLI Buildpack (`paketo-buildpacks/pnpm`)**:
   - **Detection**: Always passes. This buildpack does not gate on the presence of any file — its role is purely to resolve *which* pnpm version to provide and add it to the build plan. Version resolution is layered, in priority order:
     1. `BP_PNPM_VERSION` environment variable, if set.
     2. `packageManager` field in `package.json` (e.g. `pnpm@10.34.5`), if present.
     3. `lockfileVersion` in `pnpm-lock.yaml`, mapped to a pnpm major version (lockfile `5` → major `7`, lockfile `6` → major `8`, lockfile `N` where `N >= 9` → major `N`).
     4. Default fallback: the latest available release in the pnpm 9 major line.
   - Supports exact versions, semver constraints, and wildcards (`9`, `9.x`, `9.1.*`, `^9.1.0`, `~9.1.0`).
   - **Build Plan**:
     - Provides: `pnpm`
     - Requires: none

   Actual selection of the `pnpm` buildpack path over `yarn`/`npm` is driven entirely by whether `pnpm-install`'s detection succeeds (see below) — not by any condition in the `pnpm` CLI buildpack's own detect phase.

2. **`pnpm-install` Buildpack (`paketo-buildpacks/pnpm-install`)**:
   - **Detection**: Resolves the project path (supporting `BP_NODE_PROJECT_PATH` for monorepos, consistent with the existing npm/yarn buildpacks). Fails if `pnpm-lock.yaml` is not present in that path. Fails if `package.json` is not present in that path.
   - **Build Plan**:
     - Provides: `node_modules`
     - Requires: `node` (build time; version taken from `package.json#engines.node` when set), `pnpm` (build time; launch time controlled by `BP_PNPM_IN_LAUNCH`, see below)

### Installation & Caching Logic

- **Reproducible Installs**: `pnpm-install` runs `pnpm install --frozen-lockfile` by default.
- **Offline builds**: Before running install, the buildpack queries `pnpm config get store-dir`. If that path already exists locally, `--offline` is appended to the install command automatically, so a warm/pre-populated store enables a fully offline build without any additional configuration.
- **Production installs**: `--prod` is appended to the install command for the launch layer whenever `NODE_ENV` is not `development`.
- **Layer Caching**: `pnpm-install` uses two independent layers, `build-modules` and `launch-modules`, each reused across builds when a checksum computed from `pnpm-lock.yaml`, `package.json`, and the output of `pnpm config list` (combined with the current `NODE_ENV` value) is unchanged.
- **Service bindings**: `.npmrc` and `.pnpmrc` service bindings are symlinked into `$HOME` at build time (and cleaned up afterward). Since pnpm v10+ reads its configuration from `.npmrc`, a binding that only provides `.pnpmrc` is linked to both paths so registry/auth configuration still applies.
- **Symlink persistence across rebuilds**: `node_modules` is maintained through a symlink chain across the workspace, a temp directory, and the layer, plus a runtime `exec.d` helper that re-establishes the symlink at container start if the layer path changed between build and run.
- **Environment Variables**:
  - `BP_PNPM_VERSION`: Overrides the target `pnpm` version (highest-priority signal in both the `pnpm` and `pnpm-install` buildpacks).
  - `BP_PNPM_IN_LAUNCH`: Controls whether the `pnpm` CLI itself is included in the launch image layer, in addition to the build layer. Defaults to `true`.
  - `BP_NODE_PROJECT_PATH`: Existing Node.js language family variable; also respected by `pnpm-install` to resolve the project root in a monorepo.

### Software Bill of Materials (SBOM)

The `pnpm` CLI buildpack generates an SBOM for the delivered pnpm dependency, in CycloneDX, SPDX, and Syft formats, consistent with other Paketo dependency buildpacks. SBOM generation can be skipped with `BP_DISABLE_SBOM`.

## Rationale and Alternatives

### Alternatives Considered

1. **Relying solely on `corepack`**:
   Node.js includes `corepack` to manage package managers like `pnpm`. However, `corepack` fetches binaries on-demand at build time, which breaks air-gapped / offline build environments. Having dedicated `pnpm` buildpacks guarantees full offline capability and deterministic dependency management.

2. **Workarounds via `node-run-script` or custom hooks**:
   Users currently have to write pre-install scripts to fetch `pnpm` before running build steps. This leads to boilerplate code, inconsistent caching, and a poor developer experience compared to native buildpack support.

3. **Relying on pnpm's own store / `side-effects-cache` for build-output reuse across builds, instead of layer-based `node_modules` caching**:
   This buildpack caches the fully-installed `node_modules` directory as a CNB layer, rather than relying on pnpm's own content-addressable store (`.pnpm-store`) or its built-in `side-effects-cache` setting for reuse of build outputs across builds. This was a deliberate choice:
   - The store alone isn't sufficient for reusable native builds — pnpm's own community has confirmed `.pnpm-store` does not reliably preserve compiled native binaries (e.g. `node-gyp` output) in a way that's portable across separate cache/build steps ([pnpm/pnpm discussion #3657](https://github.com/orgs/pnpm/discussions/3657)).
   - pnpm's `side-effects-cache` has known correctness issues in exactly this kind of environment: it caches postinstall/build script results in the global store, keyed only by package version — not by OS, architecture, or Node ABI. This has caused real container build failures upstream, e.g. native binaries resolving to paths that don't exist in a different container (`ENOENT` on `mozjpeg`/`cwebp` in a GitLab CI Docker build — [pnpm/pnpm#3201](https://github.com/pnpm/pnpm/issues/3201)), and postinstall scripts being silently skipped for cached packages, breaking runtime behavior (`bcrypt` failing only in CI containers — [pnpm/pnpm discussions#7993](https://github.com/orgs/pnpm/discussions/7993)).
   - The setting meant to control this isn't reliable across pnpm versions: `side-effects-cache`'s config location moved from `.npmrc` to `pnpm-workspace.yaml` in pnpm v10.7, and even set correctly, has an open bug where it's silently ignored in some 10.7.x+ releases ([pnpm/pnpm#9394](https://github.com/pnpm/pnpm/issues/9394)). Since this buildpack supports a wide pnpm version range, depending on a setting with version-dependent location and reliability isn't a safe foundation for correctness.

   Caching the final `node_modules` output directly — the same approach the existing `npm-install`/`yarn-install` buildpacks already take — is the more predictable and version-stable strategy. This buildpack's own cache key does need to account for anything that could make a previously-built `node_modules` unsafe to reuse (e.g. the resolved Node.js version, to avoid reusing natively-compiled modules across a Node ABI change), but it does not attempt to manage or work around pnpm's internal store/side-effects caching, which remains a separate, upstream concern outside this buildpack's control.

## Implementation

The following repositories and artifacts will be created/updated:

1. **`paketo-buildpacks/pnpm`**: A new repository containing the Go codebase (using `packit`) to resolve, deliver, and shim the `pnpm` binary.
2. **`paketo-buildpacks/pnpm-install`**: A new repository containing the Go codebase (using `packit`) to execute `pnpm install` and manage layer caching.
3. **`paketo-buildpacks/nodejs`**: Update `buildpack.toml` to add the new `pnpm` order group as the first group, ahead of the existing `yarn` and `npm` groups, matching the structure of those existing groups.
4. **`paketo-buildpacks/samples`**: Add sample Node.js applications utilizing `pnpm` for integration testing and documentation.

## Prior Art

- [RFC 0008: Modular Yarn Install](0008-modular-yarn-install.md)
- [RFC 0014: Support for Yarn Berry](0014-yarn-berry.md)

## Unresolved Questions and Bikeshedding

- **Monorepo / Workspace Support**: Project-path resolution for monorepos already follows the existing Node.js language family convention (`BP_NODE_PROJECT_PATH`), the same mechanism npm and yarn buildpacks use today. What remains open is whether `pnpm`-specific workspace semantics (e.g. `pnpm-workspace.yaml`, hoisting behavior across workspace packages) need any additional handling beyond pointing at a single project path, or whether the existing convention is sufficient for initial support.
- **Order group placement**: Placing `pnpm` first (ahead of `yarn`) means a project with both a `pnpm-lock.yaml` and a `yarn.lock` present would build with `pnpm`, since `pnpm-install`'s detection only checks for its own lockfile and does not check for the absence of `yarn.lock`. This matches how the existing `yarn` group already takes precedence over `npm` for projects with both a `yarn.lock` and a plain `package.json` — per Paketo's published buildpack documentation, since the upstream `npm-install`/`yarn-install` source isn't part of this fork, `npm-install`'s detection criteria likewise only looks for a `package.json` file, with no check for `yarn.lock`. Worth confirming as the intended precedence for a three-way case regardless.
