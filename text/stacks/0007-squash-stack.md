# Squash Stack Images

## Summary

The build and run images delivered as a stack for our users should each be
squashed into a single layer to reduce the total number of layers in the
builder and application images and remove duplicated files that appear in
multiple layers.

## Motivation

Stack images act as the base image for applications and our own builder images.
Their internal layer implementations should not be important to end users.
Recently, we have been fielding a lot of bug reports wherein users cannot
create their application images because the total number of layers for the
image has exceeded the limit enforced by `containerd`.

Squashing each stack image down into a single layer will create more headroom
for both the builders and the images they create.

## Detailed Explanation

The `jam create-stack` command will include a new flag, `--squash`, that will
squash the build and run image layers each into a single layer. These squashed
images will be what the project ships as the canonical stack images for Bionic
and Jammy.

## Rationale and Alternatives

As an alternative, we could choose to add this functionality to `jam
create-stack`, but not use it as the default for the stack we ship, but allow
those with layer limit issues to squash the stacks themselves.

## Implementation

The [`crane`
CLI](https://github.com/google/go-containerregistry/tree/main/cmd/crane) has a
`flatten` command that does [this exact
operation](https://github.com/google/go-containerregistry/blob/1711cefd7eec057d3892d0bbce1bcd3f8c46d606/cmd/crane/cmd/flatten.go#L201-L254),
but against an image hosted already on a registry. We can reference this
existing code as a starting point for our own implementation that would operate
against an image as implemented within `jam create-stack`.

## Prior Art

* [`crane flatten`](https://github.com/google/go-containerregistry/blob/main/cmd/crane/doc/crane_flatten.md)
