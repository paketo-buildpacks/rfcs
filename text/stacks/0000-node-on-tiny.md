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

Additionally image scans would find less CVEs which would make it easier to assess.

| Image | Size Run Image (MB) | Total CVEs | CVEs >= 7 |
| --- | --- | --- | --- |
| run-node-tiny | 19.2 |  27 | 14 |
| paketobuildpacks/run:tiny | 17.4 | 28 | 14 |
| paketobuildpacks/run:base | 86.7 | 58 | 40 |

## Detailed Explanation

Install the [`libstdc++6`](https://packages.ubuntu.com/bionic/libstdc++6) and [`libgcc1`](https://packages.ubuntu.com/bionic/libgcc1) packages for the Ubuntu based tiny run image. It looks like this will add around 1.8 MB.

The image scan results when writing this pr "only" showed one additional CVE (5.5) which would need to be assessed.

## Rationale and Alternatives

- Node is written in C++, so it needs `libstdc++6`and `libgcc1` at runtime.
- This would also allow other apps to use the tiny stack, e.g. Rust, C++, SAP JVM
- This might be solved with the use of `extensions` which is currently discussed

## Implementation

Install the `libstdc++6` and `libgcc1` packages for the Ubuntu based tiny run image.

## Prior Art

None

## Unresolved Questions and Bikeshedding

- Is it worth to influence other users of the stack?
- Currently the `npm start` buildpack requires a `bash`, so any Node.js application using a start script would fail, but this might be changed in `npm start`
