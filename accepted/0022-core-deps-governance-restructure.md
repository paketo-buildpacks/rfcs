# Core-deps governance restructure proposal

## Summary

Currently the core-dependencies team has no formal governance structure, which is at odds with the rest of the paketo org. In order to rectify this, we are proposing
a formal governance structure that will designate specific maintainers and a contribution guide. Along with these changes will be permission restrictions following 
the paradigm of the rest of the paketo org.

## Motivation

This will bring the repos that the core-dependencies team currently manage into line with the rest of the paketo org. Currently there is no formal contribution guide, 
no set roles between maintainers and contributors and the 'core-dependencies' team itself has no direct mapping to a concept within paketo. This will bring organization
and formalization to these repositories. 

## Detailed Explanation

We plan on breaking the `core-dependencies` team into two separate teams: `stacks` and `dependencies`. The stacks team will handle all of the stacks related repos in the 
paketo org, and the dependencies team will handle all dependency related repos in the paketo org. Each of these teams will have 2 subteams: maintainers and contributors, and we will start
disallowing direct pushes to main, instead forcing contributors to open PR's and RFC's for code-base changes.

## Rationale and Alternatives

1) One alternative would be to leave things how they are and have one team. This creates problems as our team grows,
there's no clear delineation of permissions and thus everyone by default is a maintainer. Also currently without strong 
guards on pushing to main, this opens repositories to accidental damaging commits. 

1) Another alternative would be to only have one new team that manages all of the repos, but with the same strict policy changes,
including maintainer/contributor role implementation. 

1) Another alternative would be to have potentially more than two teams.
 

## Implementation

#### New Team Structure
**Stacks Team**
* Repos: stacks, base-release, full-release, tiny-release, stack-usns
* Maintainers: Mark DeLillo, Kenneth DuMez, Marty Spiewak, paketo Bot Reviewer
* Contributors: Brayan Henao, paketo Bot

**Dependencies team**
* Repos: dep-server
* Maintainers: Mark DeLillo, Kenneth DuMez, Marty Spiewak, paketo Bot Reviewer
* Contributors: Brayan Henao, paketo Bot

#### Process Changes

**Credentials** 
* Eventual goal:
    * Get rid of core-deps bot
	* Only use paketo/reviewer bot everywhere

**Permissions:** forbid push to main, must PR/RFC in changes (applies to all managed repos)

**Acceptance** 
* PRs: individual maintainers may accept
* RFCs: requires supermajority of maintainers

#### Finally
Remove existing core-dependencies team

## Prior Art

The proposed structure is heavily based on existing paketo governance. 
