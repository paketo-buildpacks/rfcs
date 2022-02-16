# Add open liberty buildpack to the Java buildpack

## Summary

[RFC 0031](https://github.com/paketo-buildpacks/rfcs/blob/main/text/0031-liberty-buildpack.md) is currently being implemented.   The liberty runtime is an application server similar to tomcat.  This RFC proposes
to add the open liberty buildpack to the Java buildpack as an alternate application server.  

## Motivation

There are a few motivations for this change:

1. The Open Liberty buildpack is not available out-of-the-box and requires manual steps to create a builder. 
2. Including the open liberty buildpack in the composite java buildpack will make it easier for customers to find and use.  
3. Other application servers can be added to the Java buildpack.

## Detailed Explanation

Currently, the Java buildpack only contributes Tomcat.  There is interest in the community for support for other Java application servers. However, the detection criteria for 
Tomcat and other servers will overlap since they can all deploy similar types of applications.  If we can accommodate multiple applications servers then we can provide a more 
well-rounded java buildpack, reach more Java communities, generate more interest in Paketo and Cloud Native buildpacks, and ultimately make it easier for user to build images for Java applications. 

## Rationale and Alternatives

Alternatives:

- Do nothing. Users of the Open Liberty buildpack will have to manually create a builder or manually specify the buildpack order, which is tedious.
- Create a new composite buildpack (was in the origin liberty buildpack RFC), however, this has discovery problems (i.e. how do users find this since it's not in the Paketo builders). It also 
requires specifying a buildpack manually.

## Implementation

In addition to the current criteria for each buildpack, the detect method will also validate itself against the value of `BP_JAVA_APP_SERVER` and contribute only if it matches. 
Tomcat will remain the default application server.

| App server         | tag          	| Buildpack                             |
| ------------       | ------------ 	| --------------------------------------|
| tomcat             | tomcat       	|  tomcat buildpack                     |
| open liberty       | openliberty  	|  open liberty buildpack 		 		|
| websphere liberty  | websphereliberty	|  open liberty buildpack				|

Additional application servers can easily be added to the Java buildpack by implementing this RFC.  

## Prior Art

- None

## Unresolved Questions and Bikeshedding

- None
