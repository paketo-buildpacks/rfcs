# Paketo Governance RFC

This RFC outlines the govornance structure for the Paketo project.

## Organizations:

Paketo consists of two github organizations:

- `paketo-buildpacks`
- `paketo-community`

The `paketo-buildpacks` github organization consists of actively supported buildpacks, libraries etc.

The `paketo-community` github organization is designed as a staging ground for acceptance into the offically supported `paketo-buildpacks` org. Promotion from `paketo-community` into `paketo-buildpacks` requires an official [`rfc`](github.com/paketo-buildpacks/rfcs)

## Contribution Model:

The paketo contribution model is divided into the following, Subteams & Roles.

- A subteam is a group responsible some set of repositories in the `paketo-buildpacks` org. This limits the repositories any individual is allowed to take action in.

- Roles are Contributor, Maintainer, And Steering Commitee member, this limits what kinds of actions an individual may be allowed to make in the `paketo-buildpacks` org

### Subteams
Subteams are responsible for maintaining some set of repositories under the `paketo-buildpacks` org. A natural split is into "Language Teams" responsible for maintaining all buildpack & specification changes that pertain to a particular language ecosystem.

In order to become a subteam member a user must be a contributor.

Subteams have ownership & voting power over relevant `rfcs`.

Both maintainers contributors & core-team members can be members on any number of Subteams.

##### Additional Responsibilities:
Each team is additionally responsible for maintaining their respective documentation at (paketo_website) as well as their README.md files in their respective repos.

### Roles

#### Contributor:
Contributors are those who make regular contributions to the project (documentation, code reviews, responding to issues, participation in proposal discussions, contributing code, etc.). 

New contributors may be self-nominated or be nominated by existing contributors, and must be elected by a supermajority of that project’s maintainers. Contributors may merge approved PRs for all subteams they are members of.

Requirements for being nominated as a Contributor:

- contribute 2 PR's under a single subteam.

#### Maintainers
Maintainers are in charge of the day to day maintenance of the team's projects. 

They review, approve, and merge PRs in all subteams they are members of, ensuring contributions align with project goals and meet the project's quality standards.

New maintainers must already be contributors, must be nominated by an existing maintainer, and must be elected by a supermajority of the steering commitee. Likewise, maintainers can be removed by a supermajority of the core team or can resign by notifying one of the maintainers.


#### Steering Commitee
The Steering Committee Members are responsible for the direction of the project (roadmap), subteam leadership, the spec, and cross-cutting concerns such as:
- Voting on all RFCS/Specification along with relevant Maintainers.
- Voting on repo's being added to this org along with effected Maintainers
- Voting on role changes (eg adding new Core Team member) 
- Voting on updating this document





