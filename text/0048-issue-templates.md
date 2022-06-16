# Additional Github Issue Templates

## Summary

Right now, there is [one issue template](https://github.com/paketo-buildpacks/.github/blob/main/ISSUE_TEMPLATE.md) configured across all of the Paketo Buildpack projects and there are none configured for Paketo Community.

## Motivation

The current template is geared towards opening a bug ticket, but doesn't make a lot of sense for a feature request. There are fields that just don't apply for feature requests and other situations.

To make it easier for users to open issues for different reasons, we'd like to create two new templates:

1. `Submit a Feature Request`
2. `Report a security vulnerability`

We'd also like to review the existing `Submit a Bug` template to see if it can be streamlined.

## Detailed Explanation

Github supports [multiple issue templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository#creating-issue-forms). We will make the change to use multiple templates and move the existing `Submit a Bug` template, plus both new templates into the templates directory.

The templates live under [.github at the Paketo Buildpacks](https://github.com/paketo-buildpacks/.github) which applies them across all of our projects.

For the Paketo Community org, we'll create a `.github` project and add the issue templates there.

## Rationale and Alternatives

1. Keep a single template, but make it more generic. This would be simpler to use, but could result in missing information we'd like to have from issues that get opened. The advantage is that this would be simple.

2. Delegate to the repo level for issue templates. It would be a challenge to keep issue templates in sync, but we have tooling in place to do this so it seems feasible. The advantage is that it would then allow individual projects to have different templates. I think in general we'd like to keep them consistent, but for repos that are quite different like stack related repos, they could have an entirely custom set of templates.

## Implementation

1. Update `.github` under the `paketo-buildpacks` Github org with the agreed upon templates.
2. Create `.github` under the `paketo-buildpacks` Github org.
3. Add the agreed upon templates.

## Prior Art

There is an existing template (prior art), which implies that we are generally sure that having templates is a good idea.

## Unresolved Questions and Bikeshedding

1. Do we need additional templates beyond the one existing and two newly proposed templates?

2. What is in each template? Including templates below.

### Submit a Bug

```markdown
<!--- Provide a general summary of the issue in the Title above -->

## Expected Behavior
<!--- Tell us what should happen -->

## Current Behavior
<!--- Tell us what happens instead of the expected behavior -->

## Possible Solution
<!--- Not obligatory, but suggest an acceptable fix for the bug -->

## Steps to Reproduce
<!--- Provide a link to an reproduction/test case, or an unambiguous set of steps to reproduce this bug. Include notes about the software versions you're using, the environment in which you're running, code snippets to reproduce, log output, screenshots, etc.. -->
1.

## Motivations
<!--- How has this issue affected you? What are you trying to accomplish? What is the impact? Providing context helps us come up with a solution that is most useful in the real world. -->
```

### Submit a Feature Request

```markdown
<!--- Provide a general summary of the request in the Title above -->

## Describe the Enhancement
<!--- Explain the change you'd like to see. Include information about how the buildpack works now and how you envision it to work after this change. -->

## Possible Solution
<!--- Not obligatory, but suggest an acceptable fix for the bug -->

## Motivation
<!--- Why do you want to see this change? What are you trying to accomplish? What is the impact? Providing context helps us come up with a solution that is most useful in the real world.  -->
```

### Report a security vulnerability

```markdown
<!--- Provide a general summary of the request in the Title above -->

## Prerequisites

* [ ] Has this security vulnerability been publicly disclosed already? **IF NO, [GO HERE](https://github.com/paketo-buildpacks/community/security/policy)**. Please do not ever disclose a security vulnerability for the first time in a public forum.

* [ ] Is this a vulnerability in a dependency installed by the buildpack? **IF YES THEN STOP**, you need to open an issue with the upstream project following their security policy. Paketo Buildpacks will pick up the fix when upstream has made it available.

* [ ] Is this a vulnerability detected by a scanner against a buildpack build/run image, stack, or buildpack generated image? **IF YES**, then [please read this first](https://paketo.io/docs/concepts/stacks/#when-are-paketo-stacks-updated). If it does not address your concern, please continue.

## Describe your Concern
<!--- Provide a summary of your concern. Include CVE numbers, if they exist.  -->

## Steps to Reproduce
<!--- Provide a link to an reproduction/test case, or an unambiguous set of steps to reproduce this vulnerability. Include notes about the software versions you're using, the environment in which you're running, code snippets to reproduce, log output, screenshots, etc.. -->
1.

## Possible Solution
<!--- Not obligatory, but suggest an acceptable fix for the vulnerability -->

## Impact
<!--- Within the context of buildpacks, what is the impact of the vulnerability? How could it be missued? Providing context helps us come up with a solution that best resolves the issue.   -->
```