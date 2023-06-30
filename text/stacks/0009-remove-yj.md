# Remove the `yj` binary from stacks

## Proposal

At the moment, all of the stacks are shipping the `yj` binary into the generated build images. Given that Paketo buildpacks are all written in Go and can read/write TOML using libraries, there doesn't seem like a need for `yj` in our stacks.

I'm proposing that we should remove it.

## Motivation

There are two motivations:

1. It's extra stuff in the build image, so it requires being kept up-to-date and it takes up space (not much, about 4.5M). It also reduces the number of layers by one.

2. Because it is distributed through a Github release, not a package manager, it is more difficult to get this binary installed into the stack with the addition of multi-arch stacks. It involves picking the right architecture and downloading the right binary for that architecture. It's not insurmountable, but it is extra work and complexity for something that appears to be extraneous to the stack.

## Implementation

In the build `Dockerfile` for each stack, there is a line like this:

```
RUN curl -sSfL -o /usr/local/bin/yj https://github.com/sclevine/yj/releases/latest/download/yj-linux-amd64 \
  && chmod +x /usr/local/bin/yj
```

This line should be removed.

## Unresolved Questions and Bikeshedding

1. Is someone actually using and depending on `yj` to be present? If so, please include your use case.
