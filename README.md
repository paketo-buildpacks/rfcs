# Paketo RFCs

## Why RFC?
The RFC (Request For Comments) process is intended to provide a consistent procedure for all major decisions effecting to Packeto Buildpacks.

## What is an RFC?
A Request For Comments starts with a document of proposed changes to Paketo Buildpack(s).
All major decisions must start with an RFC proposal.
Once an RFC has been proposed, anyone may ask questions, provide constructive feedback,
and discuss trade-offs. But only project [maintainers](todo.com) will be able to ratify an RFC.

## When to Write an RFC?
Many changes, including bug fixes and documentation improvement can be implemented and reviewed by the normal
Github pull request process.
For substantial changes, we ask that an RFC be proposed as a method to achieve consensus within the Paketo community.

#### Pull Requests / Issues
If the change is made as a pull request, but is considered substantial or more clarity/discussion is warranted, the issue will be closed and the author will be asked to be opened.

### What's in Scope
You'll need to follow this process for anything considered "substantial".
What constitutes a "substantial" change may include the following but is not limited to:
- Changes to [Paketo Spec](todo.com)
- Adding/Removing a repository to Paketo
- Changes to the contents of the Data Format file listed [here](https://github.com/buildpacks/spec/blob/master/buildpack.md#data-format)
- Changes that effect contents of the output image
- Process changes
- Governance changes

For clarification about where a change fits into this model, please review previous RFCs, or reach
out on the official Paketo slack [here](packetobuildpacks.slack.com).

### Process
#### RFCs
To get an RFC implemented, first the RFC needs to be merged into the `rfcs`[/rfcs] repo. Once an RFC is merged, it's considered 'accepted' and may be implemented in the project. These steps will get an RFC to be considered:

- Fork the RFC repo: <https://github.com/paketo-buildpacks/rfcs>
- Copy '0000-template.md' to 'accepted/0000-my-feature.md' (where 'my-feature' is descriptive. Don't assign an RFC number yet).
- Fill in RFC. Any section can be marked as "N/A" if not applicable.
- Submit a pull request. The pull request is the time to get review of the proposal from the larger community.
- Build consensus and integrate feedback. RFCs that have broad support are much more likely to make progress than those that don't receive any comments.

Once a pull request is opened, the RFC is now in development and the following will happen:

- It will be labeled as general or specific to a set of teams.
- Voting members are defined as follows:
	- If the RFC effects a single team, voting members are Steering Committee Members + Maintainers who are part of the effected team
	- If the RFC effects multiple teams, voting members are Steering Committee Members + Maintainers who are part of the effected teams. 
	- IF the RFC effects all teams, voting members are Steering Committee Members + All Maintainers

	The effect of an RFC referenced above can be defined as follows:

	- Changes inside a repo a team owns effect that team
	- If changes are proposed against a tool or utility, teams that use that utility are effected.
	- Changes to any specification that apply to a repo effect all teams that use or maintain that repo. 

- The community will discuss as much as possible in the RFC pull request directly. All discussion should be posted on the PR thread.
- When an RFC is deemed "ready"
- A Voting member may propose a "motion for final comment period (FCP)" along with a disposition of the outcome (merge, close, or postpone). Before entering FCP, super majority of the voting members must sign off.
- This step is taken when enough discussion of the trade-offs have taken place and the team(s) is in a position to make a decision.
- The FCP will last 7 days. If there's unanimous agreement among the team(s), then the FCP can close early.
- Acceptance requires a super majority of binding votes by voting members in favor. The voting options are the following: Affirmative, Negative, and Abstinence. Non-binding votes are of course welcome. Super majority means 2/3 or greater.
- If no substantial new arguments or ideas are raised, the FCP will follow the outcome decided. If there are substantial new arguments, then the RFC will go back into development.

Once an RFC has been accepted, the maintainer who merges the pull request should do the following:

- Assign an id based off the pull request number.
- Rename the file based off the id inside '/accepted'.
- Create a corresponding issue in the appropriate repo.
- Fill in the remaining metadata at the top.
- Commit everything.

### After an RFC is accepted
Once an RFC is accepted, maintaners agree to merge a corresponding PR implementing the described changes, provided it passes a standard code review.
It is not a guarantee of implementation, nor does it obligate a team to implement the requested changes.

#### Implementation
When the changes described in an RFC have been implemented and merged into the relevant repository (and thus, due to be released),
the corresponding RFC will be moved from accepted/ to implemented/. If you'd like to implement an accepted RFC,
please make a PR in the appropriate repo and mention the RFC in the PR. Feel free to do this even for work-in-progress code!

## Unresolved Questions
[unresolved-questions]: #unresolved-questions

- What clearly defines a "substantial" change?
- How long should the Final Comment Period be?

## Links

Slack : https://packetobuildpacks.slack.com

Buildpack Spec : https://github.com/buildpacks/spec

Paketo Spec : todo.com
