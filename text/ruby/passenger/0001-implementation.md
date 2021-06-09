# Passenger Buildpack Implementation

## Proposal

Create a Passenger implementation buildpack to allow for applications using
Passenger to have an official workflow.

## Motivation

Currently, there is no support for Passenger applications in the Ruby language
family. With the addition of a `passenger` buildpack, users would be able to
start a Passenger application server using the Ruby buildpackage. Passenger is
one of the [top four most popular web
servers](https://www.ruby-toolbox.com/categories/web_servers) used within the
Ruby community, so support for it could cover a large number of uses case.

## Implementation

Detection will pass is `passenger` is present in the `GEMFILE`.

On detection, the buildpack will set the start command to be `bundle exec
passenger start --port {$PORT:-3000}`.
