# Adjust Builder Order

## Summary

Presently, the Node.js buildpack is third in the detection order group for the Paketo Builders [base](https://github.com/paketo-buildpacks/base-builder/blob/main/builder.toml#L56) and [full](https://github.com/paketo-buildpacks/full-builder/blob/main/builder.toml#L62).

If you have a Go, Python, PHP or Java application that includes front-end code, in particular a `package.json` file, your application will incorrectly detect as a Node.js application and fail to build.

In most cases, the correct action would be for the buildpack to detect as Go, Python, PHP or Java. This would allow it to build the backend code and possibly use the build system to also build the front-end code. For example, it's common in the Java world to have Maven or Gradle also trigger builds of front-end code.

## Motivation

Detection can fail if you have both front-end and backend-code mixed into the project, which is a common pattern for smaller projects.

See [this issue as an example](https://github.com/paketo-buildpacks/base-builder/issues/341#issue-1086898026).

The goal of this RFC is to adjust the builder order such that this use case just works without additional configuration required.

## Detailed Explanation

Move Node.js order group to the end, just before Procfile.

```toml
[[order]]

  [[order.group]]
    id = "paketo-buildpacks/nodejs"
    version = "0.12.0"
```

Moves to be just before

```toml
[[order]]

  [[order.group]]
    id = "paketo-buildpacks/procfile"
    version = "5.0.2"
```

This will enable other buildpacks to detect before Node.js, that way if you have frontend and backend code in the same application then the correct buildpack will be selected.

The chagne to the order will not impact applications that only build using a single language family.

The potential danger with this change would be if there are Node.js applications which also include code from other language families. For example, if a Node.js application also included Python code or Ruby code.

## Rationale and Alternatives

- Adjust the Node.js buildpack detection critera so that it works in the situation described (i.e. front and backend code in the same app). It may not be possible to do this automatically though. The only option may be to have a specific env variable to force Node.js to skip, which isn't great. it also does not work out-of-the-box.
- Instruct users to use `project.toml` to exclude front-end code when building. This works, but not out-of-the-box. It presents a bad user experience because a user needs to know about this requirement and the way the failure occurs there is no opportunity to present the user with a helpful error message to instruct them to exclude these files.
- Do nothing

## Implementation

Change the order as described in the [Details Section](#detailed-explanation).

## Prior Art

The [Dotnet Core buildpack was placed earlier in the detction list for similar reasons](https://github.com/paketo-buildpacks/rfcs/blob/009ff161f7b4f05c354766eb89e0a218eef5e929/text/builders/0001-buildpack-order.md).

## Unresolved Questions and Bikeshedding

1. How can we be sure that this won't create other problems?

    - A [test was done](https://github.com/paketo-buildpacks/base-builder/issues/341#issuecomment-1004414372) with the new order and Paketo Samples all still build OK.
    - Do we need to test further?
