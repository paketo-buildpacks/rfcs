# Paketo Steering Committee Elections

## Summary

The project governance document will be amended to include a new process for
electing the membership of the project Steering Committee.

## Motivation

The Paketo Steering Committee is the set of individuals who are responsible and
accountable for guiding the Paketo project in a holistic manner towards
achieving its goals. It currently consists of three members who help to
administer the project and provide feedback and guidance on proposals that have
project-wide impact.

In the early years of the project, this group of individuals was composed of
the project founders and then by engineers with significant experience with or
contributions to the project. The technical process for voting in committee
members is outlined in the [Paketo Governance
RFC](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0002-governance.md),
but it is missing crucial detail on when and how these choices are made.

As the project has evolved to support an ever growing number of users and
contributors, it has become necessary to reassess this process and propose an
alternative that will bring in a more diverse set of experiences and
perspectives.

## Detailed Explanation

### Process Changes

#### Membership

The composition of the Steering Committee will align to the specifications,
with some modifications, outlined in the [Cloud Foundry Foundation Charter][CFF
Charter] Section 7.b. The modified contents are outlined below.

1. The Steering Committee will be composed of three (3) members.
2. Each Steering Committee member will be elected to a two-year term.
3. There will be an annual election to determine the composition of the
   Steering Committee for the following year. Two seats will be up for election
   in one year and one will be up for election the following year.
4. Employees from the same company or Related Companies (as defined in CFF
   Charter Section 9) should not hold more than one Steering Committee seat.
   a. During any Steering Committee election, if the Steering Committee
      membership would exceed this limit even after the natural cycle of Steering
      Committee seat term expirations, enough Steering Committee members must
      resign for it to be possible for the election to yield a diverse enough
      Steering Committee.
   b. If a Steering Committee election cannot produce a diverse enough Steering
      Committee, the limit will not apply until the next election cycle.
   c. When a change in employment of a Steering Committee member causes the
      Steering Committee membership to exceed this limit, that Steering Committee
      member will NOT be required to resign their Steering Committee membership.
5. One Steering Committee seat is reserved for a “community champion”, defined
   as a person NOT working for a corporation that is a paying member of the
   Cloud Foundry Foundation. If there is no champion candidate in a given
   election, this requirement is nullified.

#### Election Participation

Eligibility to participate in the Steering Committee elections process will
align to the rules, with some modifications, outlined in the [Cloud Foundry
Foundation Charter][CFF Charter] Sections 7.e.i and 7.e.ii. Their modified
contents are outlined below.

##### Candidate Eligibility

1. Current Paketo Buildpacks Steering Committee members, Subteam Maintainers or
   Contributors who have maintained that status for at least 3 months
   immediately preceding the voting.
2. If a community member is nominated as a candidate but does not meet these
   requirements, they may petition the Steering Committee for eligibility. In a
   case where the Steering Committee declines an eligibility request, the
   requestor may appeal that decision to the Cloud Foundry Governing Board.
3. Candidates, if eligible, may self-nominate or be nominated by an individual
   who is qualified as a Steering Committee voter as outlined in that section.

##### Voter Eligibility

1. Any individual who has contributed to Paketo Buildpacks in the twelve months
   prior to the election is eligible to vote in the Steering Committee
   election.
2. Contributions include, but are not limited to, opening PRs, reviewing and
   commenting on PRs, opening and commenting on issues, writing design docs,
   commenting on design docs, participating in mailing list discussions and
   participating in working groups.
3. Each election cycle, an initial set of voters will be identified through
   automated reporting. Any individual who has at least 10 measurable
   contributions in the last 12 months will be automatically added to the
   eligible voter list.
4. If a community member has contributed over the past year but is not captured
   in automated reporting, they will be able to submit an eligibility form to
   the current Steering Committee who will then determine whether this member
   will be eligible. In a case where the Steering Committee declines an
   eligibility request, the requestor may appeal that decision to the Cloud
   Foundry Governing Board.

### Implementation

The election will follow a modified version of the existing Cloud Foundry TOC
Election process and implementation outlined in the [Cloud Foundry Foundation
Charter][CFF Charter] Section 7.e.iii. The modified process is outlined below.

#### Election Method and Tools

1. If the number of candidates is equal to or less than the number of Steering
   Committee seats available to be elected, the candidates shall be approved
   after the nomination period has closed.
2. If there are more Qualified Nominees than open Steering Committee seats
   available for election, all eligible voters shall elect the Steering
   Committee members using a time-limited
   [Condorcet](https://civs.cs.cornell.edu/rp.html) ranking using the Schulze
   method.
3. Elections may be run either via the [Condorcet Internet Voting
   Service](https://civs1.civs.us/) or via a deployment of
   [Elekto](https://elekto.dev/) administered by the CFF staff.

#### Steering Committee Member Resignations or Removal

The process for handling Steering Committee member resignations or removal will
align to the rules, with some modifications, outlined in the [Cloud Foundry
Foundation Charter][CFF Charter] Sections 7.f. Their modified contents are
outlined below.

1. In the case where a Steering Committee member resigns or is removed from the
   Steering Committee by the Governing Board, the remaining members of the
   Steering Committee will work with the Governing Board to determine whether
   the vacant seat either will remain vacant until the next annual election
   cycle, or will be filled by using the results of the latest election.
2. When making this decision, the remaining members of the Steering Committee
   should consider whether too much time has elapsed since the latest election
   cycle for its results to represent the community adequately.

## Rationale and Alternatives

The current Steering Committee membership has been stable for a long period of
time. As the project and its participants evolves, the Steering Committee
membership should evolve to better represent the participants. The current
process for choosing new Steering Committee members is opaque and closed to
external participants. Establishing an open process will help to further
involve the Paketo community in the governance of their project.

Alternatively, the project could choose to keep their current processes for
choosing new Steering Committee membership. However, elections provide a much
more egalitarian process.

## Implementation

The changes outlined in the `Detailed Explanation` section will be included
into the existing governance document.

## Prior Art

* [Cloud Foundry Foundation Charter][CFF Charter]

[CFF Charter]: https://github.com/cloudfoundry/community/blob/1b04e46796bb6f21c16ef7498b9fd099eec455a4/governing-board/charter.md
