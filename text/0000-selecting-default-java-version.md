# Selecting the next default Java Version for Paketo Buildpacks

## Summary

This RFC introduces a process to select the next default version of the Paketo Java Buildpack.

## Motivation

Currently, there is no process how the default version of Java is picked in the Paketo world. As of today (January 2023), the default still is Java 11 (released September 2018) although Java 17 (released September 2021) is already available.

## Detailed Explanation

The default should be changed according to a defined process rather than at some undefined point in time to some undefined version. To do so, the default should be changed once the latest releases LTS version of Java is at least one year old. 

## Rationale and Alternatives

- Do nothing, update default manually from time to time
- Always use the latest LTS immediately
  - Could break people immediately
- This RFC
  - Gives room to adapt to breaking changes

## Implementation

To fulfill this RFC, the default version should be changed to Java 17. All future versions should be bumped according to this RFC.

## Prior Art

n/a

## Unresolved Questions and Bikeshedding

- Define the time to wait after a new LTS was published
- Should this be an automated process?
