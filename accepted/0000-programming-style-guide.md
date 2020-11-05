# Paketo Project Programming Style Guide

## Summary

This RFC proposes a Programming Style Guide for the Paketo project. It will be
used to evaluate and polish pull requests, educate contributors, and overall
maintain consistent code quality in the project

## Motivation

The Programming Style Guide will addrress the challenge of maintaining
consistent and high-quality code with excellent test coverage in an open source
project. Explicitly naming expectations will benefit both contributors of new
code and reviewers of that code in the following ways:
- Contributors (and especially first-time contributors) will have a standard
  against which to evaluate their work before opening it to outside feedback.
  They can address problems before reviewers see them.
- Contributors can refer to the Style Guide during ideation to understand which
  of their ideas are likely to a) be useful and b) play well with existing
  elements of the project.
- Reviewers can ground their feedback by citing a centralized Style Guide that
  may include more complete explanations of common feedback.
- Reviewers can be confident that their feedback covers the most important
  bases (i.e. those outlined in the Style Guide)

Maintaining a Style Guide also improves the fairness and inclusivity of the
project. Reviewers and contributors can ground their efforts in a set of
explicit and agreed upon standards, which reduces the barrier to entry for new
contributors to the project. Furthermore, standards-based feedback reduces the
amount that implicit biases about whose work is "high quality" come into play.


{{Why are we doing this? What pain points does this resolve? What use cases
does it support? What is the expected outcome? Use real, concrete examples to
make your case!}}

## Detailed Explanation

Explain the logistics of where the guide will be placed and referred to. Also
talk about guiding principles for what's included in the guide.
{{Describe the expected changes in detail.}}

## Rationale and Alternatives

1. Do nothing. For example, the [CNB project](https://github.com/buildpacks/community) functions as an open source community without a contribution Style Guide.
1. Maintain a private set of contribution guidelines that only maintainers (as PR reviewers) have access to.

While it's clear that open source projects can function without Style Guides,
the effort required to create one is not tremendous. See the sections above for
discussion of what the benefits of a Style Guide are. Keeping the Style Guide
public and accessible to contributors **before** they submit pull
requests is more in the spirit of open source transparency. It also affords
contributors the opportunity to self-edit pull requests before submitting them
to maintainers. A well-written, publicly available Style Guide can increase code quality and
consistency in a project while transferring some of the responsibility of
maintaining code quality from maintainers onto contributors themselves.

## Implementation

The proposed Paketo Project Style Guide is as follows:

### Style Guide

#### Buildpack Design Best Practices
1. Keep `Detect` and `Build` functions as small as possible.
1. Only add a requirement to a buildpack if it's necessary for the buildpack to run.
1. Only add a provision to a buildpack if it actually supplies something for
   itself or a subsequent buildpack to use.

#### Testing
1. Please write tests for your contributions to the Paketo project.
1. If your contribution changes or adds to the API of a buildpack, you'll
   likely need to change or add integration tests.
1. If your contribution changes how the `detect` or `build` executables of a
   buildpack work, you'll likely need to change or add unit tests.

#### Preferred Code Structures
1. Many Paketo buildpacks are written in Go. If you are contributing Go, please
   write [Effective Go](https://golang.org/doc/effective_go.html).

1. When reviewing Pull Requests, maintainers may refer to these [Common Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments).

1. If you're writing in a shell scripting language, keep [this Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
   in mind.
   * In particular, check out the "When to use Shell" section to consider if
     it's time to switch languages.

## Prior Art

* [Effective Go](https://golang.org/doc/effective_go.html)
* [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
* [Common Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
* [Spring Boot Contribution Guidelines](https://github.com/spring-projects/spring-boot/blob/master/CONTRIBUTING.adoc#code-conventions-and-housekeeping)

<< Link to other project style guides that are useful/effective. >>

## Unresolved Questions and Bikeshedding

{{Write about any arbitrary decisions that need to be made (syntax, colors,
formatting, minor UX decisions), and any questions for the proposal that have
not been answered.}}

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
