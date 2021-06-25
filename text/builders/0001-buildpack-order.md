# Proposed Buildpack Ordering in a Builder

## Summary

`pack inspect-builder gcr.io/paketo-buildpack/builder` should display a valid `Detection Order`.

## Motivation

After a change to the builder detection order it became impossible for `php` apps to detect, because `nginx` and `httpd` were before `php` in the detect order. 
The `httpd.conf` or `nginx.conf` included in `php` apps will cause the `nginx` or `http` buildpacks to detect `true` before `php` ever gets to run `detect`,
making it impossible to access the `php` buildpack.


## Detailed Explanation

We propose the following order based on the historical needs of app developers:

- paketo-buildpacks/staticfile
- paketo-community/ruby
- paketo-buildpacks/dotnet-core
- paketo-buildpacks/nodejs
- paketo-buildpacks/go
- paketo-community/python
- paketo-buildpacks/php
- paketo-buildpacks/nginx
- paketo-buildpacks/httpd
- paketo-buildpacks/java
- paketo-buildpacks/procfile

Any new buidpack will need careful consideration before deciding its place in the order.

## Rationale and Alternatives

An alternative solution can be found [here](https://github.com/paketo-buildpacks/builder/pull/22), in which we propose an algorithm to order buildpacks.

This was rejected because, based on experience in cloud foundry, we found that a certain ordering makes the most sense for the most developers.

For example, dotnet-core apps often contain `package.json` files, so `dotnet-core` must come before `nodejs`.

Also, `staticfile` must come first because it can not infer detection from the source code, but must rely on `buildpack.yml` property.
