# Co-locate All Paketo RFCs

## Summary

All individual repository level RFCs that are in the Paketo organization should
be centralized into the top level RFCS repository.

## Motivation

As it stands currently there are RFCs scattered across various repositories
throughout the Paketo organization. These RFCs pertain typically to the
implementation and functionality of either entire language families or even on
down to implementation buildpack specific behavior. While it is good to have a
record of technical decisions made for the project and its components, it is
sometimes hard to search for relative RFCs for a given language family or
feature. By co-locating all of the RFCs for the project into one repository we
will collect all of the decision making conversation into one place making it
easier to access.

## Implementation

Each [project team](https://github.com/orgs/paketo-buildpacks/teams) will be
given a directory inside of the `rfcs` repository, which would be named after
the project team. A series of directories with the same names as the
repositories that fall under that project teams control will be created inside
of the project team's sub-directory.
```
rfcs
├── assets
│   └── ...
├── LICENSE
├── NOTICE
├── README.md
└── text
    ├── 0000-template.md
    ├── ...
    └── project-team
        └── repository
```
The maintainers of that project team will be given control over their directory
through the `CODEOWNERS` file located in the `.github` directory of the
repository. Currently this repository is set to require a review from at least
one CODEOWNER, so by configuring the `CODEOWNERS` folder with the [correct prioirity](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners#example-of-a-codeowners-file)
ordering a maintainer on the project team could review and merge an RFC created
in their sub-directory with no intervention from the steering committee.

Example of the `CODEOWNERS` file [(note priority is from top to bottom of the `CODEOWNERS` file)](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/about-code-owners#example-of-a-codeowners-file):
```
*                  @paketo-buildpacks/steering-committee
text/project-team/ @paketo-buildpacks/project-team-maintainers
```


## Rationale and Alternatives

- We could co-locate all of the RFCs for any given language family into the top
  level language family buildpack repository. This would help collect the
  information to an extent while allowing for the separation of language
  specific information from the top level repository. This also allows for
  easier commiting of RFCs by maintainers and contributors because they would
  not need to create a fork of the repository to create an RFC. This still puts
  a burden on individuals that would like to keep track of the going ons of
  lots of teams.

## Unresolved Questions and Bikeshedding

- Is there a way to set up permissions to allow for project team members to
  open up RFCs inside their respective language directories without having to
  fork the RFCs repository? Should we just give all maintainers and
  contributors of the Paketo project the ability to create and push branches to
  the RFCs repository?

{{REMOVE THIS SECTION BEFORE RATIFICATION!}}
