# Support PNPM Package Manager in Node.js Language Family

## Summary

This RFC proposes adding first-class support for the `pnpm` package manager in the Paketo Node.js language family. This includes introducing a `pnpm` CLI dependency buildpack and a `pnpm-install` buildpack to manage application dependencies using `pnpm-lock.yaml`.

## Motivation

`pnpm` has seen widespread adoption across the JavaScript ecosystem due to its performance, disk space efficiency via content-addressable storage, and robust monorepo/workspace support. Major frameworks and open-source projects (such as Vue.js, Vite, Svelte, and Nuxt) now officially recommend or exclusively use `pnpm`.

Currently, the Paketo Node.js language family natively supports `npm` and `yarn`. Adding native support for `pnpm` will allow developers and organizations using `pnpm` to build container images out-of-the-box without relying on custom workarounds or pre-install scripts.

## Detailed Explanation

### Architecture & Buildpack Composition

Following the modular Paketo Node.js architecture (as defined in RFC 0001 and RFC 0008), we propose adding two new implementation buildpacks:

1. **`pnpm`**: Downloads and installs the `pnpm` CLI binary into a layer and adds it to `$PATH`.
2. **`pnpm-install`**: Handles dependency installation by executing `pnpm install` and managing `node_modules` or the pnpm store.

### Buildpack Order Grouping & Detection Precedence

In the composite `nodejs` meta-buildpack (`paketo-buildpacks/nodejs`), a new order group will be added **before** the standard `npm` order group.

Because `npm` detection succeeds on any project containing a `package.json` file (acting as the default fallback for Node.js applications), placing the `pnpm` order group higher in the precedence chain ensures that the presence of `pnpm-lock.yaml` will correctly select the `pnpm` buildpacks over `npm`.

The updated order groups in `paketo-buildpacks/nodejs` will be structured as follows:

```toml
# 1. Yarn Order Group (Existing)
[[order]]
  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/watchexec"
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

# 2. PNPM Order Group (New)
[[order]]
  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/watchexec"
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

# 3. NPM Order Group (Existing Fallback)
[[order]]
  [[order.group]]
    id = "paketo-buildpacks/ca-certificates"
    optional = true
  [[order.group]]
    id = "paketo-buildpacks/watchexec"
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
```

### Detection Logic & Build Plan Contracts

1. **`pnpm` CLI Buildpack (`paketo-buildpacks/pnpm`)**:
   - **Detection**: Passes if `pnpm-lock.yaml` is present in the working directory OR if `BP_PNPM_VERSION` environment variable is set.
   - **Build Plan**:
     - Provides: `pnpm`
     - Requires: `node` (at build time)

2. **`pnpm-install` Buildpack (`paketo-buildpacks/pnpm-install`)**:
   - **Detection**: Passes if `pnpm-lock.yaml` and `package.json` are present in the working directory.
   - **Build Plan**:
     - Provides: `node_modules`
     - Requires: `node` (at build time), `pnpm` (at build time)

### Installation & Caching Logic

- **Reproducible Installs**: By default, `pnpm-install` will run `pnpm install --frozen-lockfile` to enforce strict lockfile adherence.
- **Layer Caching**: The buildpack will configure `pnpm` to use a dedicated cache layer for the pnpm store (e.g., via `pnpm config set store-dir <layer-path>`). This layer will be marked `cache = true` to dramatically accelerate rebuilds.
- **Environment Variables**:
  - `BP_PNPM_VERSION`: Allows users to specify or override the target `pnpm` version.
  - `BP_PNPM_INSTALL_ARGS`: Allows users to pass additional flags to `pnpm install`.

## Rationale and Alternatives

### Alternatives Considered

1. **Relying solely on `corepack`**:
   Node.js includes `corepack` to manage package managers like `pnpm`. However, `corepack` fetches binaries on-demand at build time, which breaks air-gapped / offline build environments. Having dedicated `pnpm` buildpacks guarantees full offline capability and deterministic dependency management.

2. **Workarounds via `node-run-script` or custom hooks**:
   Users currently have to write pre-install scripts to fetch `pnpm` before running build steps. This leads to boilerplate code, inconsistent caching, and a poor developer experience compared to native buildpack support.

## Implementation

The following repositories and artifacts will be created/updated:

1. **`paketo-buildpacks/pnpm`**: A new repository containing the Go codebase (using `packit`) to download and install the `pnpm` binary.
2. **`paketo-buildpacks/pnpm-install`**: A new repository containing the Go codebase (using `packit`) to execute `pnpm install` and manage layer caching.
3. **`paketo-buildpacks/nodejs`**: Update `buildpack.toml` to include the new `pnpm` order group.
4. **`paketo-buildpacks/samples`**: Add sample Node.js applications utilizing `pnpm` for integration testing and documentation.

## Prior Art

- [RFC 0008: Modular Yarn Install](0008-modular-yarn-install.md)
- [RFC 0014: Support for Yarn Berry](0014-yarn-berry.md)

## Unresolved Questions and Bikeshedding

- **Monorepo / Workspace Support**: How should `pnpm` workspaces (`pnpm-workspace.yaml`) be handled when building sub-packages? Should it be automatically detected, or should a `BP_PNPM_WORKSPACE_FRAMEWORK` / `BP_NODE_PROJECT_PATH` variable be configured?
