# Support for JavaScript Frontend applications

## Summary

The Web Servers language family should support JavaScript frontend applications
that required a build process to transform their codebase into a deployable
artifact. The Web Servers language family will adopt several of the buildpacks
available in the Node.js language family to create an order grouping capable of
building these types of frontend applications.

## Motivation

It is a common practice for web applications to be split between a backend that
serves an API and a frontend that runs in a browser. Today, we have many
choices to help developers deploy their backend applications in many of the
most popular programming languages. However, for developers looking to build a
container capable of serving their frontend, we do not have a solution that
works well out of the box.

## Detailed Explanation

All of the parts necessary to develop this addition to the Web Server language
family already exist, but have not yet been pulled together into a consistent
whole. Specifically, we will be adding the existing `node-engine`,
`npm-install`, `yarn`, `yarn-install`, and `node-run-script` buildpacks to the
order groupings list to enable this outcome.

## Rationale and Alternatives

### Alternative: Do nothing

We could choose not to directly support this through a language family
buildpack. In fact, we tell users today that want to build this type of
application that it can be achieved manually using the consituent pieces of the
Node.js buildpack and a web server. Based on the continued requests for
first-class support of this type of application, it is clear that we would be
missing an obvious user need.

### Alternative: Include this in the Node.js Buildpack

We could include this group ordering in the Node.js buildpack itself. However,
this starts to muddy the waters of what a Node.js application is. The Node.js
buildpack is purpose built to support applications that run `node` inside the
container. This is commonly a backend server application, but could also be
something like a React server that is acting in both a backend and frontend
capacity. Either way, the image that gets built contains `node`.

In the proposed usecase, `node` is really just needed during the build process
to convert some JavaScript into a bundled static file that is then served by a
web server. This type of application is a pattern that can be found in a number
of language ecosystems beyond just Node.js. For example, Hugo (Go), Jekyll
(Ruby), MkDocs (Python), and mdBook (Rust) all provide a similar process to
convert some intermediate development files into a set of static assets to be
served by a web server. In the future, it may make sense to include optimized
buildpack groups to support these other toolkits as well.

## Implementation

The `buildpack.toml` file for the Web Servers buildpack will now include the
following order groupings:

```
[[order]]

  [[order.group]]
    id = "paketo-buildpacks/node-engine"

  [[order.group]]
    id = "paketo-buildpacks/yarn"

  [[order.group]]
    id = "paketo-buildpacks/yarn-install"

  [[order.group]]
    id = "paketo-buildpacks/node-run-script"

  [[order.group]]
    id = "paketo-buildpacks/nginx"

[[order]]

  [[order.group]]
    id = "paketo-buildpacks/node-engine"

  [[order.group]]
    id = "paketo-buildpacks/npm-install"

  [[order.group]]
    id = "paketo-buildpacks/node-run-script"

  [[order.group]]
    id = "paketo-buildpacks/nginx"
```

In order to detect either of these groups, users will need an application that
is using either NPM or Yarn to install their packages. These are detected by
the presence of a `package.json` or `yarn.lock` file. Additionally, users will
need to specify the `BP_NODE_RUN_SCRIPTS` environment variable indicating how
to go about building their application. Finally, users will need to include an
`nginx.conf` file that is configured to serve the build result static files.

## Unresolved Questions and Bikeshedding

* Should we support more than just `nginx` as the web server?
