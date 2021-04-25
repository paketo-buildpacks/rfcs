# Deploy and customize triage party for Paketo community use

## Summary

Host an instance of [Triage Party](https://github.com/google/triage-party) at `triage.paketo.io` to asist with issue triage, priortization and to keep an eye on community health using basic metrics like average issue response time and number of open PRs across all of Paketos repositories.

## Motivation

Keeping on top of all open issues, PRs and comments from the community and deciding which potential work to priortize is challenging. There is not an easy way to get visibility into the health of the community in terms of the age of open issues, issues requiring a response, and PRs awaiting review across all repositories.

## Detailed Explanation

The [Paketo project](https://paketo.io) is made up of many git repositories across the [paketo-buildpacks](https://github.com/paketo-buildpacks) and [paketo-community](https://github.com/paketo-community) Github orgs. These repositories contain implementation buildpacks, language family buildpacks, and auxiliary repositories related to managing the Paketo project and its community. **As of late April, 2021, there are 113 repositories across Paketo's two Github orgs.** At any given time each repository can have open issues in various stages of triage, and open pull requests requing the attention of language family maintainers and others in the community.

## Rationale and Alternatives

Triage party provides unified views, filters, and metrics across repositories that can be customized to the needs of the Paketo project and community. Triage party is open source and already used by several large projects including [Minicube](http://tinyurl.com/mk-tparty) and [skaffold](http://tinyurl.com/skaffold-tparty)

While there are a number of comercial services that could allow us to more easily triage issue across repositories their primary purpose is more around providing unified Kanban boards (Something Triage Party could also do) and licening costs may not allow these comercial services to be shared widly with the community. Because Triage Party provides read only views across n repositories there are also no user accounts or permissions to administer.

Paketo has an an existing custom built dashboard at https://dashboard.paketo.io which gives you an overview of issue counts and a unified list of open issues. While this dashboard is great as a quick way to glance at the state of repos it suffers from a few shrotcommings:

 1. It requires each user to provide their personal github token which is a barier to use.

 1. There is no included rules engine that can be easily customized via a configuration file. Changes to filtering and and other enhancments require additional engineering time.

 1. Given the breadth of the languages and buildpacks the Paketo project supports and the number of full time engineers known to be working on the project and current level of overal contributors, it's unlikley that the dashboard software will get much sustained development going forward.

Finaly, Github search is somewhat useful and can be used to search for labels across repositories with some accuracy in a given Org. This approach, however, does not provide the at a gance overview of all repositories and metrics available by Triage Party.

## Implementation

If accepted the following changes will be made:

* A repository will be created at `github.com/paketo-buildpacks/triage-party-config`

* Triage Party's `config.yml` file will be customized for our needs. As one example, we can update the config to add a page for issues that have been labeld as `status/possible-priority` to allow maintainers to nominate issues to be scheduled for work.

* A Github access token will be created by a Paketo controlled service account for use with Triage Party - this is required for Triage Party to pull data from Github. Triage Party has mechinism in place to ensure that data is cached and Githubs ratelimits are not reached for a given access token.

* A maintainer will be nominated to implement and maintain the instance of Triage Party or responsibliyty will be added to the Paketo tooling maintainers.

Github actions will be set up in the new repo to deploy Triage Part as follows: 

* Changes to `config.yml` will be made on or merged into a `develop` branch. 

* Any changes to the `develop` branch will kick off a deploy to a staging evironment at (perhaps) `triage-stage.paketo.io`. Once the deployment has been validated the changed can be merged to `main` and the application will be deployed to `triage.paketo.io`.

* A deployment mechinism will be put in place to deploy new releases of Traige Party to stage and then prod.

## Prior Art

* [Devstats](https://github.com/cncf/devstats) is a tool created by the [CNCF](https://www.cncf.io) that does not focus on Triage but does collect a richer set of [detailed project and contributor metrics] than Triage Party. It's also used by [GraphQL](https://devstats.graphql.org/) and [CD.FOUNDATION projects](https://devstats.cd.foundation).

## Unresolved Questions and Bikeshedding

* What [customizations](https://github.com/google/triage-party/blob/master/docs/config.md) should be made to the default configuration to best serve the Paketo project?

* Where should we deploy Triage party? So far there is a [POC](https://triage-party-2-kpyaivtu7a-uc.a.run.app/s/daily) running on Google Cloud run. Triage Party can also be installed on a single vm using the local disk as a cache. This may require additional configuration (Terraform) but *may* offer better performance.

* We have a lot of repositories and while Triage Party caches data locally we don't know if the number of repos affect the tools performance and limit its usefulness.