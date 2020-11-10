# Contributor Guidelines

## Summary

This RFC aims to formalize the contribution process for the Paketo organization
through the creation of a detailed contribution guide and support materials
such as pull request and issue templates.

These support materials will live in the
[community repository](https://github.com/paketo-buildpacks/community).

## Motivation

It would be useful to formalize and surface guidelines for contributing to the
Paketo organization, so that members of the community know where to start when
they seek to contribute. The addition of pull request and issue templates will
allow contributors to articulate their contributions/concerns more effectively,
creating a more efficient and open contribution process.

## Detailed Explanation

Include the following templates in each repository where users might reasonably
contribute:

---

# `CONTRIBUTING.md`

The Paketo Buildpacks organization welcomes contributions from everyone.
Formally, contributions are given as pull requests for a given repository. To
contribute to a repository, follow the steps below:

## How do I contribute?

1. Fork the repo you'd like to make a contribution to
1. Clone your fork to your local workstation
1. Create a new branch for the issue
1. Make the necessary changes on that branch
1. Commit and push to that branch
1. Make a pull request against the repo
1. Sign the Contributor Licensing Agreement, if necessary

## Where can I look for issues?

We tag issues that should be reasonable for a new contributor to take on with a
[`good first
issue`](https://github.com/search?q=org%3Apaketo-buildpacks+org%3Apaketo-community+label%3A%22good+first+issue%22+state%3Aopen&type=Issues)
label so you have somewhere to start.

## Where can I reach out to the team?

- _Want to report concerns/bugs?_ Create an issue on the affected repo.
- _Usage issues/help?_ Reach out to us on [Slack](https://slack.paketo.io/).
- _Want to participate in deeper architectural discussions?_ Attend our weekly
  [working group
  meetings](https://github.com/paketo-buildpacks/community#working-group-meetings).

## I've been contributing for a while. How do I join the Paketo Buildpacks organization?

The Paketo organization is divided into teams that are responsible for the
maintenance of some subset of repositories belonging to a particular domain
(e.g. Node.js, Python, Golang).

For each team, there are two tiers of participants:

- Contributors
- Maintainers

### How do I become a contributor?

Becoming a contributor requires a history of interaction with repositories
under a given team's jurisdiction (e.g. `node-engine` repo for the Node.js
team).

Once this history has been established, you may self-nominate or be nominated
by an existing contributor or maintainer. Each new contributor must be elected
by a super-majority of the team maintainers.

One way to self-nominate is by creating an issue on the language-family repo
for a given team. You can find an example of a [self-nomination
issue](https://github.com/paketo-buildpacks/ruby/issues/409) on the Ruby
buildpack repository. This nomination included links to contributions made as
justification for nomination and was approved by a super-majority of the team
maintainers.

### How do I become a maintainer?

New maintainers must already be contributors, must be nominated by an existing
maintainer, and must be elected by a supermajority of the steering committee.

## Code of Conduct

It is expected that all contributors, formal or otherwise, follow the [Code of
Conduct](
https://www.contributor-covenant.org/version/2/0/code_of_conduct/code_of_conduct.md).
Enforcing this code is an expectation of all organization members.

---

# `ISSUE_TEMPLATE.md`

## What happened?

Please provide some details about the task you are trying to accomplish and
what went wrong.

* What were you attempting to do?

* What did you expect to happen?

* What was the actual behavior? Please provide log output, if possible.

## Build Configuration

Please provide some details about your build configuration.

* What platform (`pack`, `kpack`, `tekton` buildpacks plugin, etc.) are you using? Please include a version.

* What buildpacks are you using? Please include versions.

* What builder are you using? If custom, can you provide the output from `pack
  inspect-builder <builder>`?

* Can you provide a sample app or relevant configuration (`buildpack.yml`,
  `nginx.conf`, etc.)?

## Checklist

Please confirm the following:

* [ ] I have included log output.
* [ ] The log output includes an error message.
* [ ] I have included steps for reproduction.

---

# `PULL_REQUEST_TEMPLATE.md`

Thanks for contributing. To speed up the process of reviewing your pull request
please provide us with:

* A short explanation of the proposed change:

* An explanation of the use cases your change enables:

Please confirm the following:
* [ ] I have viewed, signed, and submitted the Contributor License Agreement.
* [ ] I have added an integration test, if necessary.

---

## Unresolved Questions and Bikeshedding

* Should these documents go into a `.github` repository?

* Is the org bound by any legal restrictions? What guarantees or statements do
  we want to make about contributor IP?

* How should users report security vulnerabilities? This should be recorded in
  a `SECURITY.md`.
