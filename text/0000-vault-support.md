# Vault Support

## Summary

Introduce an (optional) buildpack into each language buildpack family. 
The buildpack will be responsible for enabling consumers to retrieve secrets from [HashiCorp Vault](https://github.com/hashicorp/vault) at container runtime.

## Motivation

The goal is to standardize HashiCorp Vault secret retrieval by providing this functionality via a Buildpack. 
This has the added benefit of improving convenience and simplifying the developer experience.

Providing a mechanism for Buildpacks to enable secret retrieval standardizes access and enhances convenience, thus simplifying the developer experience.

## Detailed Explanation

Retrieving secrets from HashiCorp Vault is a commonly required task for containerized applications.

A Paketo buildpack can be developed to enable containerized applications to retrieve/inject secrets at application runtime. 
This would provide an alternative to using deployment platform-specific secrets management (e.g. AWS Secrets Manager) or requiring developers to manage
this directly in application code. 

This buildpack would be optional and available in each language buildpack family.


## Rationale and Alternatives

Implementing a Buildpack solution for this enables standardization/automation of HashiCorp Vault secrets retrieval.

Without a Buildpack solution, users are forced to:

1  - Leverage their deployment platform

However, there are many circumstances where this is not a desired option and it should instead be handled at the container level.
(For example HashiCorp Vault can be hosted on-prem or you may need a cloud provider-agnostic solution for secrets management)

Paketo Buildpacks can instead be leveraged to provide Vault secrets management access here.

2 - Implement it themselves (container/application level)

This forces a lot of re-inventing the wheel.
By moving this into a Buildpack, there is significant benefit to standardizing/automating the handling of secrets retreival.

## Implementation

N/A - Skipping this section during the initial proposal as it is not yet required.

## Unresolved Questions and Bikeshedding

N/A