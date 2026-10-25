# Consolidate the libbs buildpacks into a single `build-tools` repository

## Summary

Introduce a new `paketo-buildpacks/build-tools` repository that holds the
implementation for the JVM build tool buildpacks (Gradle, Maven, sbt, Clojure
Tools, and Leiningen) in one codebase, seeded from `libbs`. The repository emits
one buildpack per tool using the existing `paketo-buildpacks/gradle`,
`paketo-buildpacks/maven`, `paketo-buildpacks/sbt`,
`paketo-buildpacks/clojure-tools`, and `paketo-buildpacks/leiningen` IDs, and a
combined `paketo-buildpacks/build-tools` buildpack that supports all five. Once
the new repository is publishing, retire and archive `libbs`, `gradle`,
`maven`, `sbt`, `clojure-tools`, and `leiningen`.

## Motivation

The Java build tool buildpacks are five separate repositories, each with its own
copy of the same plumbing, plus `libbs`, a shared library all of them import:

- `paketo-buildpacks/gradle`
- `paketo-buildpacks/maven`
- `paketo-buildpacks/sbt`
- `paketo-buildpacks/clojure-tools`
- `paketo-buildpacks/leiningen`
- `paketo-buildpacks/libbs` (shared application, cache, and resolver code)

This has a few costs:

1. **Maintenance over six codebases.** The same application build/cache logic
   lives in `libbs` and is wired up five times. Each repository has its own
   workflows, release process, lint/test setup, and dependency update pipelines.
2. **Version churn.** A `libbs` change requires a release plus five pull
   requests to consume it, one per buildpack.
3. **Duplicated dependency update pipelines.** Each build tool is retrieved by a
   separate workflow in a separate repository, even though the handling is
   nearly identical.
4. **Inconsistent test coverage and CI.** Each repository drifts; some have stale
   tests that no longer run under their pipeline.

`jvm-vendors` already demonstrates a better model: one repository that contains
the shared implementation and emits a buildpack per variant plus a combined
buildpack. Applying the same model to the libbs buildpacks reduces the number of
repositories from six to one without changing what users consume.

The expected outcome is that consumers see no change: the per-tool buildpack IDs
and published image names stay the same. Maintainers get one codebase, one
dependency pipeline, and one release process.

## Detailed Explanation

### New repository

Create `paketo-buildpacks/build-tools`, seeded with:

- the `libbs` code, as a local package (no git history from `libbs`)
- the Gradle, Maven, sbt, Clojure Tools, and Leiningen detection, distribution,
  and build implementations
- a combined detect/build path that runs the tool detectors in order and
  dispatches the build to the detected tool

The detection order is Leiningen, Clojure Tools, Gradle, Maven, then sbt,
matching the order those buildpacks appear in the `java` language family
buildpack. A new `BP_BUILD_TOOLS` configuration (default
`leiningen,clojure-tools,gradle,maven,sbt`) controls both the set of enabled
tools and that precedence. The per-tool artifacts default it to a single tool.

### Emitted buildpacks

`scripts/package.sh` uses a new `libpak-tools build-build-tools` command
(the same mechanism as `libpak-tools build-jvm-vendors` for `jvm-vendors`) to
emit six buildpacks from the one source tree:

| Buildpack | Contents | Published image |
| --- | --- | --- |
| `paketo-buildpacks/leiningen` | Leiningen only | `paketobuildpacks/leiningen` |
| `paketo-buildpacks/clojure-tools` | Clojure Tools only | `paketobuildpacks/clojure-tools` |
| `paketo-buildpacks/gradle` | Gradle only | `paketobuildpacks/gradle` |
| `paketo-buildpacks/maven` | Maven and Maven Daemon | `paketobuildpacks/maven` |
| `paketo-buildpacks/sbt` | sbt only | `paketobuildpacks/sbt` |
| `paketo-buildpacks/build-tools` | All tools | `paketobuildpacks/build-tools` |

Each generated buildpack rewrites its `buildpack.toml` metadata (ID, name,
description, homepage, version), keeps only the dependencies and constraints
for its tool, and defaults `BP_BUILD_TOOLS` to that tool. The per-tool images
keep their current names and tags, so existing users and the current
`java`/`java-native-image` order groups do not change.

### Compatibility

- Buildpack IDs, image names, and tags for Leiningen, Clojure Tools, Gradle,
  Maven, and sbt are unchanged.
- All existing configuration options are preserved, including `BP_LEIN_*`,
  `BP_CLJ_*`, `BP_GRADLE_*`, `BP_MAVEN_*`, `BP_SBT_*`, `BP_INCLUDE_FILES`,
  `BP_EXCLUDE_FILES`, `BP_JAVA_INSTALL_NODE`, and `BP_NODE_PROJECT_PATH`.
- SBOM entries, CPEs, PURLs, and layer behavior are preserved. Dependency
  metadata is regenerated with the same conventions and checksums as today.
- The new combined `paketobuildpacks/build-tools` image is additive.
- The per-tool images (`paketobuildpacks/leiningen`,
  `paketobuildpacks/clojure-tools`, `paketobuildpacks/gradle`,
  `paketobuildpacks/maven`, and `paketobuildpacks/sbt`) continue to be published
  indefinitely alongside `paketobuildpacks/build-tools`. There are no plans to
  drop them in favor of only the combined image.

### Testing images and retiring the old repositories

The rollout publishes test images first, so existing consumers and composites
are never affected while the new repository is validated. The existing per-tool
images use the same `-dev` suffix that `jvm-vendors` uses today.

1. Publish the first release of `build-tools`. The combined buildpack is a new
   image, so it is published directly as `paketobuildpacks/build-tools`. The
   per-tool buildpacks already have production image names, so they are
   published under test names for now: `paketobuildpacks/leiningen-dev`,
   `paketobuildpacks/clojure-tools-dev`, `paketobuildpacks/gradle-dev`,
   `paketobuildpacks/maven-dev`, and `paketobuildpacks/sbt-dev`. The production
   per-tool image names and the composites are untouched.
2. Announce the testing images in a blog post, with instructions for trying
   them and reporting feedback.
3. Validate the testing images, including using them in the `java` and
   `java-native-image` composite orders on a branch or draft.
4. Move publishing of the production image names (`paketobuildpacks/leiningen`,
   `paketobuildpacks/clojure-tools`, `paketobuildpacks/gradle`,
   `paketobuildpacks/maven`, and `paketobuildpacks/sbt`) over to `build-tools`,
   and switch the `java` and `java-native-image` order groups to the
   `build-tools` artifacts in the same coordinated release (per-tool or
   combined, see [Unresolved Questions](#unresolved-questions-and-bikeshedding)).
5. Announce the production switch, and leave a 30 day window for feedback.
6. Archive the `libbs`, `gradle`, `maven`, `sbt`, `clojure-tools`, and
   `leiningen` GitHub repositories. This stops their workflows.
7. Do **not** delete the Docker Hub tags. Those image names continue to be
   published from `build-tools`.

## Implementation

The highlights:

1. Create `paketo-buildpacks/build-tools` from the `libbs` and build tool code:
   `libbs/`, `leiningen/`, `clojure-tools/` (or `clojure/`), `gradle/`,
   `maven/`, `sbt/`, a combined `buildtools/` package, and `run/main.go`.
2. Add `buildpack.toml` with the Leiningen, Clojure, Gradle, Maven, Maven
   Daemon, and sbt dependency constraints and the merged configuration options.
3. Add `dependency/retrieval` to fetch Leiningen, Clojure, Gradle final
   releases, Maven 3/4 from Maven Central, Maven Daemon per-architecture GitHub
   release assets, and sbt from GitHub releases. The existing retrieval code in
   `clojure-tools` and `leiningen` can be ported as-is.
4. Add `libpak-tools build-build-tools` (in `paketo-buildpacks/libpak-tools`),
   modeled on `build-jvm-vendors`, with a catalog entry per tool.
5. Add `scripts/package.sh` to emit the six buildpacks, plus release and
   publish workflows that handle all six artifacts and images.
6. Adopt the shared `github-config` implementation workflows, with unit tests
   and linting in CI. Integration testing stays at the composite
   (`java`/`java-native-image`) level, as it is today for `jvm-vendors`.
7. Release `build-tools` under test image names, announce the testing images,
   validate them (including in the `java`/`java-native-image` composites on a
   branch), then move the production image names and composite order groups
   over, wait 30 days, and archive `libbs`, `gradle`, `maven`, `sbt`,
   `clojure-tools`, and `leiningen`.

Repositories affected:

- **New:** `paketo-buildpacks/build-tools`
- **Archived:** `paketo-buildpacks/libbs`, `paketo-buildpacks/gradle`,
  `paketo-buildpacks/maven`, `paketo-buildpacks/sbt`,
  `paketo-buildpacks/clojure-tools`, `paketo-buildpacks/leiningen`
- **Changed:** `paketo-buildpacks/libpak-tools` (new `build-build-tools`
  command)
- **No change during testing:** `paketo-buildpacks/java`,
  `paketo-buildpacks/java-native-image`; their order groups are updated in the
  coordinated production switch

The starting implementation covers Gradle, Maven, and sbt. Clojure Tools and
Leiningen are ported into the repository as part of the implementation before
the first release.

## Rationale and Alternatives

Several alternatives were considered:

1. **Do nothing.** Keep six repositories and duplicate CI and dependency
   pipelines. This is the status quo and the source of the maintenance cost
   above.
2. **Merge everything into one buildpack without per-tool artifacts.** This
   would remove the per-tool images that users pin today and require changing
   the `java` and `java-native-image` order groups. It would be a breaking
   change for no functional benefit.
3. **Keep `libbs` as a separate library and have `build-tools` depend on it.**
   This retains an additional repository and the version-bump loop. Copying the
   code into `build-tools` is what `jvm-vendors` did with the JVM code and keeps
   the new repository self-contained.

The approach described in this document keeps the per-tool artifacts that users
consume, avoids mixing component buildpack code into the language family
composite, and consolidates maintenance into one repository. It also makes
adding another build tool later a matter of adding a catalog entry and an
implementation package rather than creating a new repository.

## Prior Art

- `paketo-buildpacks/jvm-vendors` already consolidates the JVM vendor
  buildpacks into one repository that emits a buildpack per vendor plus a
  combined buildpack, using `libpak-tools build-jvm-vendors`.
- [RFC 0008: Consolidate Python package managers buildpacks](../python/0008-consolidate-python-package-managers.md)
  proposes pooling several tool-specific buildpacks into fewer shared
  codebases.
- [RFC 0004: Merge Java Feature-Flag Buildpacks](0004-merge-java-feature-flag-buildpacks.md)
  reduced the number of Java buildpacks by folding behavior into `libjvm`.
- [RFC 0018: Retire Java Azure Composite Buildpack](0018-retire-java-azure-composite.md)
  describes the process used to archive a buildpack repository.

## Unresolved Questions and Bikeshedding

- Should `java` and `java-native-image` reference the combined
  `paketo-buildpacks/build-tools` buildpack, or keep using the per-tool
  buildpacks? Either works; the per-tool buildpacks keep the change invisible.
- Is a 30 day deprecation window appropriate for a change that keeps buildpack
  IDs and image names stable?
