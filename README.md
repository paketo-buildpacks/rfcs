# Paketo RFCs

## Accepted RFCs

* [0015: Distribute Buildpacks via Docker Hub](./text/0015-dockerhub-distribution.md)
* [0017: Paketo Community Go HTTP Function Buildpack](./text/0017-go-http-fn.md)
* [0019: Default Behaviour for Buildpack-Set Language Ecosystem Environment Variables](./text/0019-buildpack-set-env-vars-defaults.md)
* [0027: Common Logging Levels for Buildpacks](./text/0027-log-levels.md)
* [0032: Reloadable Process Types](./text/0032-reloadable-process-types.md)
* [0037: Remote Debug](./text/0037-remote-debug.md)
* [0040: Auto-generate Reference Documentation](./text/0040-auto-reference-docs.md)
* [0041: Use Direct Processes and exec.d](./text/0041-direct.md)
* [0044: Provide Global Mechanism to Disable SBOM Generation](./text/0044-disable-sbom.md)
* [0045: Secure runtime environments](./text/0045-user-ids.md)
* [0046: Define an Image & Dependency Retention Policy for Paketo Images](./text/0046-image-retention-policy.md)
* [0052: Graceful Stack Upgrades](./text/0052-graceful-stack-upgrades.md)
* [0055: Create Language Family Builders](./text/0055-create-language-family-builders.md)
* [0056: Stacks & Extensions for UBI base images. (UBI8)](./text/0056-ubi-based-stacks.md)

## Implemented RFCs

* [0001: Paketo Repo Migration Proposal](./text/0001-repo-migration.md)
* [0002: Paketo Governance](./text/0002-governance.md)
* [0004: Leiningen (Clojure) Buildpack](./text/0004-clojure.md)
* [0005: Ruby Paketo Buildpack Promotion](./text/0005-ruby-promotion.md)
* [0006: Web Servers Buildpack Subteam](./text/0006-web-servers.md)
* [0007: Paketo Buildpack Naming](./text/0007-buildpack-naming.md)
* [0008: Paketo Community](./text/0008-paketo-community.md)
* [0009: Dep Server to provide buildpack dependency metadata](./text/0009-dep-server.md)
* [0010: Dependency Mappings](./text/0010-dependency-mappings.md)
* [0012: Builders Subteam](./text/0012-builder-subteam.md)
* [0013: Contributor Guidelines](./text/0013-contributing-guidelines.md)
* [0014: Paketo Community Rust Buildpack](./text/0014-rust.md)
* [0016: Paketo Project Programming Style Guide](./text/0016-programming-style-guide.md)
* [0018: Radiate Buildpack and Community Metadata via a Dashboard](./text/0018-dashboard.md)
* [0020: Self-host our blog via Hugo and GitHub Pages](./text/0020-blog.md)
* [0021: Paketo Community Go Generate Buildpack](./text/0021-go-generate-buildpack.md)
* [0022: Core-deps governance restructure proposal](./text/0022-core-deps-governance-restructure.md)
* [0023: Git Support](./text/0023-git-buildpack.md)
* [0024: Utility Buildpacks Team](./text/0024-utility-buildpacks-team.md)
* [0025: Establishing an Emeritus Status](./text/0025-emeritus-status.md)
* [0026: Environment Variable Configuration Of Buildpack](./text/0026-environment-variable-configuration-of-buildpacks.md)
* [0028: Co-locate All Paketo RFCs](./text/0028-co-locate-all-rfcs.md)
* [0029: Semantic Versioning of Buildpacks and Builders](./text/0029-semantic-versioning.md)
* [0030: Buildpackless Builders](./text/0030-buildpackless-builders.md)
* [0031: Liberty Buildpack](./text/0031-liberty-buildpack.md)
* [0034: Update Hash Field in Bill of Materials](./text/0034-hash-field-bom.md)
* [0035: Python Paketo Buildpack Promotion](./text/0035-python-promotion.md)
* [0036: Explorations Repository](./text/0036-explorations.md)
* [0038: Support for CycloneDX and Syft SBoM](./text/0038-cdx-syft-sbom.md)
* [0039: Semantic Versioning in Tags for Buildpacks](./text/0039-semantic-version-tags.md)
* [0042: Adjust Builder Order](./text/0042-adjust-builder-order.md)
* [0043: Expanding the Criteria for Reproducible Builds](./text/0043-reproducible-builds.md)
* [0047: Web Servers Buildpack Promotion](./text/0047-promote-web-servers-buildpack.md)
* [0048: Additional Github Issue Templates](./text/0048-issue-templates.md)
* [0050: Rename Buildpacks](./text/0050-buildpack-rename.md)
* [0051: Contribute APM Tools Buildpacks](./text/0051-apm-tools.md)
* [0053: Create static stack](./text/0053-add-static-stack.md)

## Superseded RFCs

* [0003: Replace buildpack.yml with Build Plan (TOML)](./text/0003-replace-buildpack-yml.md)
* [0033: Implement a Bill of Materials Across Paketo](./text/0033-bill-of-materials.md)

## Why RFC?
The RFC (Request For Comments) process is intended to provide a consistent procedure for all major decisions affecting Paketo Buildpacks.

## What is an RFC?
A Request For Comments starts with a document of proposed changes to Paketo Buildpack(s).
All major decisions must start with an RFC proposal.
Once an RFC has been proposed, anyone may ask questions, provide constructive feedback,
and discuss trade-offs. But only the [steering committee or team maintainers](https://github.com/paketo-buildpacks/community/blob/main/TEAMS.md) will be able to ratify an RFC for project-level and team-level RFCs, respectively.

## When to Write an RFC?
Many changes, including bug fixes and documentation improvement can be implemented and reviewed by the normal
Github pull request process.
For substantial changes, we ask that an RFC be proposed as a method to achieve consensus within the Paketo community.

#### Pull Requests / Issues
If the change is made as a pull request, but is considered substantial or more clarity/discussion is warranted, the issue will be closed and the author will be requested to open new issues.

### What's in Scope
You'll need to follow this process for anything considered "substantial".
What constitutes a "substantial" change may include the following but is not limited to:
- Adding/Removing a repository to Paketo
- Changes to the contents of the Data Format files defined [here](https://github.com/buildpacks/spec/blob/main/buildpack.md#data-format)
- Changes that affect the contents of the output image
- Process changes
- Governance changes

For clarification about where a change fits into this model, please review previous RFCs, or reach
out on the official [Paketo Slack](https://paketobuildpacks.slack.com).

## Project-Level vs. Team-Level RFCs

If the changes proposed in the RFC are scoped to a specific sub-team, please open a team-level RFC. If the proposal will affect the multiple teams or the entire project please open a project-level RFC.

Examples of project-level RFCs:
- Process changes that affect all teams
- New conventions that should be adopted by all buildpacks
- A proposal to add a standard configuration option to every buildpack (e.g. `BP_LOG_LEVEL`)
- Changes to the governance structure
- Change to the RFC process

Examples of teams-level RFCs:
- A proposal to support a workflow or feature in a particular language family (e.g. support building Java apps with Gradle)
- A proposal to add a configuration option to a particular language family buildpacks
- Process changes that affect a single team

### Process
#### RFCs
To get an RFC implemented, first the RFC needs to be merged into the [`rfcs`](//github.com/paketo-buildpacks/rfcs) repo. Once an RFC is merged, it's considered 'accepted' and may be implemented in the project. These steps will get an RFC to be considered:

- Fork the RFC repo: <https://github.com/paketo-buildpacks/rfcs>
- Copy 'text/0000-template.md' to 'text/0000-my-feature.md' or 'text/<project-team>/0000-my-feature.md' for project-level or team-level RFCs respectively, where 'my-feature' is descriptive of the proposal (Don't assign an RFC number yet).
- Fill in RFC. Any section can be marked as "N/A" if not applicable.
- Submit a pull request. The pull request is the time to get review of the proposal from the larger community.
- Build consensus and integrate feedback. RFCs that have broad support are much more likely to make progress than those that don't receive any comments.

Once a pull request is opened, the RFC is now in development and the following will happen:

- It will be labeled as general or specific to a set of teams.
- Voting members are defined as follows:
	- If the RFC affects a single team, voting members are Steering Committee Members + Maintainers who are part of the affected team
	- If the RFC affects multiple teams, voting members are Steering Committee Members + Maintainers who are part of the affected teams. 
	- IF the RFC affects all teams, voting members are Steering Committee Members + All Maintainers

	The effect of an RFC referenced above can be defined as follows:

	- Changes inside a repo a team owns affect that team
	- If changes are proposed against a tool or utility, teams that use that utility are affected.
	- Changes to any specification that apply to a repo affect all teams that use or maintain that repo. 

- The community will discuss as much as possible in the RFC pull request directly. All discussion should be posted on the PR thread.
When an RFC is deemed "ready"
- A Voting member may propose a "motion for final comment period (FCP)" along with a disposition of the outcome (merge, close, or postpone). Before entering FCP, supermajority of the voting members must sign off.
- This step is taken when enough discussion of the trade-offs have taken place and the team(s) is in a position to make a decision.
- The FCP will last 7 days. If there's unanimous agreement among the team(s), then the FCP can close early.
- Acceptance requires a supermajority of binding votes by voting members in favor. The voting options are the following: Affirmative, Negative, and Abstention. Non-binding votes are of course welcome. Supermajority means 2/3 or greater.
- If no substantial new arguments or ideas are raised, the FCP will follow the outcome decided. If there are substantial new arguments, then the RFC will go back into development.

Once an RFC has been accepted, the maintainer who merges the pull request should do the following:

- Assign an incremental ID (e.g. if currently 12 accepted project-level RFCs, assign ID 0013. If there are 3 accepted NodeJS team RFCs assign ID 0004).
- Rename the file, replacing `0000` with the assigned ID.
- Create a corresponding issue in the appropriate repo.
- Fill in the remaining metadata at the top.
- Commit everything.

### After an RFC is accepted
Once an RFC is accepted, maintainers agree to merge a corresponding PR implementing the described changes, provided it passes a standard code review.
It is not a guarantee of implementation, nor does it obligate a team to implement the requested changes.

#### Implementation
When the changes described in an RFC have been implemented and merged into the relevant repository (and thus, due to be released),
the corresponding RFC will be moved from accepted/ to implemented/. If you'd like to implement an accepted RFC,
please make a PR in the appropriate repo and mention the RFC in the PR. Feel free to do this even for work-in-progress code! If
you'd like to track progress on an RFC implementation, check if an issue has been opened that requests the RFC be implemented. If not, feel
free to open one.

## Unresolved Questions
[unresolved-questions]: #unresolved-questions

- What clearly defines a "substantial" change?
- How long should the Final Comment Period be?

## Links

[Slack](https://paketobuildpacks.slack.com/join/shared_invite/zt-ded61bqr-Rw_uK3u6MvaeLPhxEIBcLg)

[Buildpack Spec](https://github.com/buildpacks/spec)
