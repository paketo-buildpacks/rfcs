# Radiate Buildpack and Community Metadata via a Dashboard

## Summary
<!-- A concise, one-paragraph description of the change. -->

The [Paketo website](https://paketo.io) should include a new subdomain
(`https://dashboard.paketo.io`) that displays details about the current status
of buildpacks and other community information. This type of metadata helps the
core development team keep on top of open issues and PRs while also making that
information transparent for external community members.

## Motivation
<!--
Why are we doing this? What pain points does this resolve? What use cases does
it support? What is the expected outcome? Use real, concrete examples to make
your case!
-->

While GitHub notifications and search can provide some amount of insight into
the overall health and state of the Paketo buildpack orgs, finding answers to
many questions is not a simple task.  I personally have found myself with
multiple tabs pinned in my browser showing a number of different details about
the state of buildpacks across the orgs. I'd like to know:

* Which repos have lots of issues or PRs that need to be addressed?
* Do we have unreleased bug fixes or features on our mainline branches waiting to be released?
* Which issues/PRs have been open the longest?
* What buildpack spec API version is each buildpack using?
* What is the mean/median/95th percentile "time to merge" for PRs closed recently?
* Which PRs have been approved?
* Which PRs have passed all their checks?
* What dependencies are included in the latest released buildpacks?

This is just a small sampling of the many questions I find myself wanting to
answer as a developer responsible for dozens of buildpacks at this point. Quite
a few of them are also questions I've seen buildpack users ask in places like
our Slack instance or repo issues. As the Paketo Buildpacks ecosystem has
grown, it has become more difficult to keep on top of many of these questions.

Creating a place where the community can collaborate to encode and expose
answers to these questions in a common location would help us to scale up our
processes in answering some of these questions. It would also aid our userbase
in enabling a self-service location for them to find answers to their own
questions.

## Detailed Explanation
<!-- Describe the expected changes in detail -->

For my own needs, and to aid the existing Paketo core development team, I have
[spiked](https://github.com/ryanmoran/paketo-dashboard) out a
[dashboard](https://ryanmoran.github.io/paketo-dashboard/) that has started to
provide answers for some of these questions.

![Yarn Install Buildpack Metadata](/assets/dashboard-yarn-install-tile.png)

As an example, this tile is able to tell me that the `yarn-install` buildpack
has 4 open issues, and 0 open pull requests. The issue count is color-coded to
indicate that I might want to take notice of the growing number of unaddressed
issues. Additionally, I can see that the most recent release was `v0.2.2` and
that there have been 6 commits to the `main` branch since that release.

Most of this information can be found by just visiting the `yarn-install`
repository itself. The dashboard doesn't really provide much benefit when
viewed from the perspective of a single repository. However, when viewed in
aggregate, I can start to get a better view of the current state of the
buildpacks.

![Buildpack Metadata Partial Dashboard](/assets/dashboard-partial.png)

Now I can start to see patterns. I can see that some of the Java buildpacks
have accreted a fair number of commits since their last release. I can see that
we should maybe spend some more time looking at the Node.js and PHP buildpacks
to understand why they've got so many open issues. And as these details change,
I can refocus my energy knowing where it is needed most.

## Rationale and Alternatives
<!--
Discuss 2-3 different alternative solutions that were considered. This is
required, even if it seems like a stretch. Then explain why this is the best
choice out of available ones.
-->

1. Rely on existing tooling.

   Between the existing set of search and notifications features offered by
   GitHub, we might be able to get by without a dashboard like what is being
   proposed. This might be reasonable for the core development team, but is
   likely to be a painpoint for the buildpack userbase.

## Implementation
<!--
Give a high-level overview of implementation requirements and concerns. Be
specific about areas of code that need to change, and what their potential
effects are. Discuss which repositories and sub-components will be affected,
and what its overall code effect might be.

THIS SECTION IS REQUIRED FOR RATIFICATION — you can skip it if you don't know
the technical details when first submitting the proposal, but it must be there
before it's accepted.
-->

The dashboard codebase is a relatively simple React web app that queries the
GitHub API to summarize high-level details of the state of the Paketo
Buildpacks ecosystem. It is currently hosted via GitHub Pages, and it would be
relatively simple to transfer the repository into the existing
`paketo-buildpacks` org and redeploy it from there.

The [Paketo website](https://paketo.io) would then include a subdomain called
`dashboard.paketo.io`. This subdomain would serve the web app.

1. Adopt the [`paketo-dashboard`
   repository](https://github.com/ryanmoran/paketo-dashboard) into the
   `paketo-buildpacks` org, under the Tooling subteam.
2. Publish the dashboard repository via GitHub Pages.
3. Map the GitHub Pages URL for the dashboard repository to `https://dashboard.paketo.io`.

## Prior Art
<!--
This section is optional if there are no actual prior examples in other tools.
Discuss existing examples of this change in other tools, and how they've
addressed various concerns discussed above, and what the effect of those
decisions has been.
-->

* [Cloud Foundry Buildpack Dashboard](https://buildpacks.cloudfoundry.org/#/buildpacks)
  Provides a UI to view details about the contents of Cloud Foundry buildpack releases.

* [Paketo Buildpacks Action Status Dashboard](https://github.com/arjun024/actions-dashboard-paketo)
  An organized collection of the action status badges for all the repositories in the Paketo orgs.

* [Time-to-Merge Calculator](https://github.com/paketo-buildpacks/github-config/tree/main/scripts/time-to-merge)
  A command-line program to calculate the mean/median/95th percentile "time to merge" metric for the Paketo org repositories.
