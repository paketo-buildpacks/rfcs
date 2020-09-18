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

{{Discuss 2-3 different alternative solutions that were considered. This is
required, even if it seems like a stretch. Then explain why this is the best
choice out of available ones.}}

## Implementation

The proposed Paketo Project Style Guide is as follows:

### Style Guide

#### Buildpack Design Best Practices
1. Keep `Detect` and `Build` functions as small as possible.
2. Only add a requirement to a buildpack if it's necessary for the buildpack to run.

#### Testing
How much testing is enough testing?

#### Preferred Code Structures
1. Many Paketo buildpacks are written in Go. If you are contributing Go, please
   write [Effective Go](https://golang.org/doc/effective_go.html)



{{Give a high-level overview of implementation requirements and concerns. Be
specific about areas of code that need to change, and what their potential
effects are. Discuss which repositories and sub-components will be affected,
and what its overall code effect might be.}}

{{THIS SECTION IS REQUIRED FOR RATIFICATION -- you can skip it if you don't
know the technical details when first submitting the proposal, but it must be
there before it's accepted.}}

## Prior Art

Link to other project style guides that are useful/effective.  {{This section
is optional if there are no actual prior examples in other tools.}}

{{Discuss existing examples of this change in other tools, and how they've
addressed various concerns discussed above, and what the effect of those
decisions has been.}}

## Unresolved Questions and Bikeshedding

{{Write about any arbitrary decisions that need to be made (syntax, colors,
formatting, minor UX decisions), and any questions for the proposal that have
not been answered.}}

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
