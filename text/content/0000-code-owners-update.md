# Use CODEOWNERS File to Delegate Change Approval Responsibility

## Summary

To submit a change to Paketo documentation, you must submit a PR and the PR needs to be approved. Currently, this requires approval from someone on the Content team. If this is a technical change with the documentation for a specific buildpack, the Content team may not have someone familiar with the technical material to validate and approve the change. This also creates a bottleneck on the Content team.

This RFC proposes that we modify the CODEOWNERS file such that we delegate responsibility for approving PRs for specific technical subsets of the documentation content in the Paketo documentation to the language family teams.

## Motivation

1. Reduce overhead on the Content team
2. Enable language family teams to own their sections of the documentation

## Detailed Explanation

We require CODEOWNERs to approve a PR before it can be merged. The CODEOWNERS file can be broken down such that different Github teams can own different parts of a repository.

Here is the proposed breakdown for the CODEOWNERS file on the [paketo-buildpacks/paketo-website](https://github.com/paketo-buildpacks/paketo-website/) project.

```text
*                                            @paketo-buildpacks/content-maintainers

content/getting-started-languages/java.md    @paketo-buildpacks/java-buildpacks
content/getting-started-languages/nodejs.md  @paketo-buildpacks/nodejs-maintainers
content/getting-started-languages/python.md  @paketo-buildpacks/python-maintainers

content/docs/howto/java.md                   @paketo-buildpacks/java-buildpacks
content/docs/howto/nodejs.md                 @paketo-buildpacks/nodejs-maintainers
content/docs/howto/python.md                 @paketo-buildpacks/python-maintainers
content/docs/howto/ruby.md                   @paketo-buildpacks/ruby-maintainers
content/docs/howto/php.md                    @paketo-buildpacks/php-maintainers
content/docs/howto/web-servers.md            @paketo-buildpacks/php-maintainers
content/docs/howto/go.md                     @paketo-buildpacks/go-maintainers
content/docs/howto/dotnet-core.md            @paketo-buildpacks/dotnet-core-maintainers
content/docs/howto/configuration.md          @paketo-buildpacks/utilities-maintainers

content/docs/reference/java-reference.md               @paketo-buildpacks/java-buildpacks
content/docs/reference/java-native-image-reference.md  @paketo-buildpacks/java-buildpacks
content/docs/reference/nodejs-reference.md             @paketo-buildpacks/nodejs-maintainers
content/docs/reference/python-reference.md             @paketo-buildpacks/python-maintainers
content/docs/reference/ruby-reference.md               @paketo-buildpacks/ruby-maintainers
content/docs/reference/php-reference.md                @paketo-buildpacks/php-maintainers
content/docs/reference/nginx-reference.md              @paketo-buildpacks/php-maintainers
content/docs/reference/httpd-reference.md              @paketo-buildpacks/php-maintainers
content/docs/reference/go-reference.md                 @paketo-buildpacks/go-maintainers
content/docs/reference/dotnet-core-reference.md        @paketo-buildpacks/dotnet-core-maintainers
```

## Rationale and Alternatives

- Do nothing. We may need to explore adding more folks to the content team, such that technical maintainers overlap with the content maintainers team.

## Implementation

1. Modify the CODEOWNERS file as listed above.
2. Done

## Prior Art

The [paketo-buildpacks/samples](https://github.com/paketo-buildpacks/samples) does this now.

## Unresolved Questions and Bikeshedding

N/A
