# Add to Tiny Run Image to Enable Node Apps

## Summary

At the moment, Node.js applications are not compatible with the tiny builder. Therefor the `nodejs` buildpack does not support the tiny stack.

The tiny build image is already capable of building the Node.js application.

The tiny run image is missing `libstdc++6`and `libgcc1`.

## Motivation

To support running Node.js applications with the tiny builder.

While not all Node.js applications could be supported by that, this could be a feasible approach:

- `tiny`: Run Node.js applications **without** any native extenstions
- `base`: Run Node.js applications **without** many native extensions
- `full`: Run Node.js applications **with** many native extensions

This should be desirable as some types of Node.js application would benefit of the reduced image size.

```bash
apps/node-tiny                        latest     7546c8d45780   41 years ago   130MB
apps/node-base                        latest     022cb9cea147   41 years ago   202MB
apps/node-full                        latest     1324267830ec   41 years ago   803MB
```

## Detailed Explanation

Install the [`libstdc++6`](https://packages.ubuntu.com/bionic/libstdc++6) and [`libgcc1`](https://packages.ubuntu.com/bionic/libgcc1) packages for the Ubuntu based tiny run image. It looks like this will add around 1.8 MB.

```bash
run-node-tiny                        latest     43acd28c97af   41 years ago   19.2MB
paketobuildpacks/run:tiny            latest     fa34fc0b3d7b   41 years ago   17.4MB
```

## Rationale and Alternatives

1. Node is written in C++, so it needs `libstdc++6`and `libgcc1` at runtime.

## Implementation

Install the `libstdc++6` and `libgcc1` packages for the Ubuntu based tiny run image.

## Prior Art

None

## Unresolved Questions and Bikeshedding

- Is it worth to influence other users of the stack?
- Currently the `npm start` buildpack requires a `bash`, so any Node.js application using a start script would fail.
