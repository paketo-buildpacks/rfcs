# Image Distribution via ECR

## Summary

Amazon Elastic Container Registry (ECR) is Amazon's implementation of the [OCI Distribution Specification][distribution-spec]. The RFC proposes publishing all Paketo Buildpack, Stack, and Builder images to [ECR Public][ecr-public] in addition to DockerHub (our primary distribution channel to date).

## Motivation

Publishing images to ECR will improve the experience of using Paketo buildpacks in AWS, whether that is with [AWS App Runner][app-runner] as [proposed][app-runner-roadmap] in the App Runner roadmap or with platforms such as [kpack][kpack] on [tekton][tekton-task] running on [Amazon Elastic Kubernetes Service][eks] (EKS).

The first way this will improve the Paketo+AWS experience is by enhancing performance. Pulling and pushing images is generally fastest when working within (e.g. ECR -> EKS) rather than across (e.g GCR -> EKS) cloud provider ecosystems. Keeping copies of the run image and builpack images in ECR should enable peak performance for build/rebase/create-builder with [cross-repo blob mounting][cross-repo-blob-mount] when the created images are also public. This may not apply to private images in ECR due to differing registry hostnames (although the ggcr team has an [experimental cross-origin blob mount proposal][cross-origin-blob-mount] that would allow registries like ECR to enable this).

Second, working within a single cloud provider ecosystem allows users to take advantage of idiomatic access control mechanisms such as [node-identity][node-identity] or [workload-identity][workload-identity] based registry authentication. While this is probably unnecessary given Paketo images are public and our Dockerhub account should be exempt from rate limiting, hosting images in ECR removes any ambiguity, allowing users to work entirely within a comfortable toolchain.

## Detailed Explanation

The project has already been given an AWS organization funded by the CFF and we have requested the [custom alias][registry-alias] `paketo-buildpacks` for our public registry. We should take the additional step of contacting support and verifying this account so that our repositories will have a verified badge on the ECR Public Gallery (click on any [heroku buildpack][heroku-gallery] repository in the gallery for an example).

A copy of all image artifacts including releases of buildpack, builder, and stack images should be published there in addition to Dockerhub. In cases where we have changes the repo/tag schema we should only use the newer names - because ECR images are net new backwards compatibility is not a concern in this context.

Examples:
- `public.ecr.aws/paketo-buildpacks/builder-jammy-base:0.3.13`
- `public.ecr.aws/paketo-buildpacks/java:latest`
- `public.ecr.aws/paketo-buildpacks/run-jammy-tiny:latest`

### Costs
Given we will be using public repositories, data transfer in is free. Data transfer out without an AWS account is free but limited by source IP. Data transfer out is free within AWS and up to 5TB per months outside of AWS.

Assuming we are unlikely to go over the external data transfer limits, our costs would be limited to storage fees of `$0.10` per GB / month (See [ECR pricing][ecr-pricing] for details).

Some very rough, back of the envelope math...

For simplicity assume:
1. We do not need to pay twice for blobs that are mounted across repos.
2. The full builder contains a superset of the buildpack + stack blobs.
3. There are ~600 version of the builder within the retention policy at any given time (looks like we have published 559 to Dockerhub so far).
4. The full builder grows to `2GB` (It is currently `1.89GB`).

The CFF will pay `600 * 2GB * $0.10/GB = $120` per month for storage. This is well within reason, even if many of these simplifying assumptions turn out to be wrong and the bill is 5x my rough estimate.

### Other Cloud Providers

The stated rationale for this RFC above could apply just as well to other public cloud provides such as Google Cloud, and Azure. We do not intend to favor Amazon and should expand distribution to other major cloud provider registries given:
1. Costs are reasonable
2. We have a request from real world users or potential users
3. We believe doing so will increase the reach of Paketo buildpacks

Because it is inherently a judgement call to determine what cloud providers are "major" and what costs are "reasonable", given the opportunity and number of potentially impacted users, each new distribution target should be ratified via the RFC process.

## Rationale and Alternatives

### Alternative 1 - Do Nothing
We could not do this and require AWS users to consume Paketo images from Dockerhub. If a group like the App Runner team wishes to provide Paketo images on ECR to enhance the App Runner experience they could copy images to an ECR public repo.

If we go this route we run the risk of letting a third party fill the vacuum, becoming the default distributors of Paketo buildpacks on ECR. This may present a reputational risk to to the project and a security risk to end users.

### Alternative 2 - Publish to All the Cloud Providers
We could assume the above logic will apply to other cloud providers with large market share such as Google and Azure cloud and approve these additional distribution target now. However, I suggest we decided each case individually and in response to community interest. This allows us to keep costs in check and learn from this experience before committing to publishing every image everywhere.

### Alternative 3 - Do a Subset of Images

We could publish just the builder image and run images to ECR, assuming these are the most useful to end users. Given automating fewer images doesn't save us much time and the projected costs are reasonable, I don't see much point in doing this. If we publish buildpack images to ECR, app developers can use the gallery to explore the available buildpacks.

## Implementation

### Migration

We will add a step to our existing automation to push released images to ECR in addition to Dockerhub. We will not copy over previously published images. Images in ECR should be subject to the approved retention policy.

### Access

We should follow the [principle of least privilege][least-privilege] with our AWS organization. A bot user will be created with the minimal set of permissions needed to write images to the registry. This account will be used to automate releases.

The only human users with access to the organization will be the steering committee all of whom must enable [multi-factor authentication][mfa]. Should any maintainer need to access the account they should discuss their use case with the steering committee.

### Run Image Mirror

The corresponding ECR run image should be added to each Paketo builder as a run-image mirror.

## Prior Art

Heroku publishes Cloud Native Buildpack [images][heroku-gallery] to ECR Public in addition to Dockerhub.


[distribution-spec]: https://github.com/opencontainers/distribution-spec
[ecr-public]: https://docs.amazonaws.cn/en_us/AmazonECR/latest/public/what-is-ecr.html
[app-runner]: https://aws.amazon.com/apprunner/
[app-runner-roadmap]: https://aws.amazon.com/apprunner/
[dockerhub-rfc]: https://github.com/aws/apprunner-roadmap/issues/11
[kpack]: https://github.com/pivotal/kpack
[tekton-task]: https://hub.tekton.dev/tekton/task/buildpacks
[eks]: https://aws.amazon.com/eks/
[cross-repo-blob-mount]: https://github.com/distribution/distribution/issues/634
[cross-origin-blob-mount]: https://github.com/google/go-containerregistry/pull/1388
[node-identity]: https://docs.aws.amazon.com/AmazonECR/latest/userguide/ECR_on_EKS.html
[workload-identity]: https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html
[registry-alias]: https://docs.aws.amazon.com/AmazonECRPublic/latest/APIReference/API_RegistryAlias.html
[heroku-gallery]: https://gallery.ecr.aws/heroku-buildpacks/
[ecr-pricing]: https://aws.amazon.com/ecr/pricing/
[least-privilege]: https://en.wikipedia.org/wiki/Principle_of_least_privilege
[mfa]: https://aws.amazon.com/iam/features/mfa/

