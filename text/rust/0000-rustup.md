# Paketo Community Rustup Buildpack

## Summary

The primary way of installing Rust is through a tool called `rustup`. It would be nice if we can support using `rustup` as another means of installing Rust.

## Motivation

We have bypassed using `rustup` in the rust-dist CNB by directly downloading a full Rust distribution and installing that. This has limitations such as the file is large, it's specific to an architecture & toolchain, and it's not feasible to do nightly builds that way. Using the `rustup` tool provides us with additional flexibility, plus it gives users the primary means through which they are used to having Rust installed. If a user needs to customize or make some adjustments, they are much more likely to be familiar with doing so through `rustup`.

## Detailed Explanation

Right now we have two buildpacks: rust-dist and cargo install. The former provides the Rust installation and the latter uses Cargo to compile source code. This proposal would add a third buildpack called rustup. Users would pick to either use rust-dist or rustup. The default would be to use rustup, given that is what most users will expect and it's more flexible. We'll continue to retain rust-dist as this may be easier for some users in offline environments.

## Rationale and Alternatives

- Do nothing. We'll miss out on use cases we could service.
- Update rust-dist to cover some of the gaps, such as having nightlies and being able to install additional toolkits. This would be technically possible but would require some extreme automation, given that nightlies come out, well, nightly (which would imply we'd do the same with rust-dist). It would also require more entries in buildpack.toml if we're to support more toolkits.

## Implementation

The idea is to have a build plan like this:

1. The rustup buildpack will provide both rust and rustup.
2. The rust-dist buildpack will not change and will continue to provide rust.
3. The cargo-install buildpack will change and will now provide two buildplans. Both will provide and require cargo. The first will require rust. The second will require rust and rustup.

The idea is that we have a buildplan which will allow for either rust-dist and cargo-install to be used together or we'll have a buildplan that allows for rustup and cargo-install to be used together. When the rustup buildpack runs, it will consume the rustup and rust requirements from the buildplan and so the rust-dist buildpack while it still runs will effectively do nothing (i.e. it only installs rust if the rust requirement has not been yet met). Optionally, a builder could remove rust-dist or rustup if the builder author had a preverence for one over the other.

Since a user cannot manipulate the buildplan directly, we are exposing two ways that a user can control which method is used to install Rust.

1. Through an environment variable. We will add `BP_RUSTUP_ENABLED` which the rustup buildpack will examine. If it's true, which is the default, then the buildpack will proceed to use Rustup to install Rust. If it's set to false, the buildpack will do nothing, which will allow for some other buildpack, presently that's just rust-dist, to install Rust.
2. Through a custom builder. A user could compose their own builder without the rustup buildpack, which would allow them to select a different buildpack for installing Rust.

## Prior Art

The rustup buildpack works similar to rust-dist. It provides the Rust toolchain on the `$PATH` and sets `$CARGO_HOME` so it can be consumed by `cargo-install`, which doesn't care how the Rust toolchain is installed.

The buildplan structure is modeled after the Java buildpack, which also supports multiple providers for the Java toolchain.

## Unresolved Questions and Bikeshedding

- N/A
