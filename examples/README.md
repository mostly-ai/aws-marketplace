---
About: Terragrunt examples for MostlyAI Marketplace Installation
RepositoryOwner: mostlyai-devops
DocumentationOwner: mostlyai-devops
---

# Installation Example

> This article goes over the installation process following the terragrunt units in current directory. If you are looking for a more general installation overview, please refer to the [repository guide](../README.md) at the root of the repository.

- [Installation Example](#installation-example)
  - [Prerequisites](#prerequisites)
  - [Terragrunt Stacks](#terragrunt-stacks)
  - [Installation](#installation)
  - [Post-Installation](#post-installation)

## Prerequisites

Before you begin, ensure you have the following prerequisites in place:

1. **AWS Authentication** configured in your environment. Examples assume that you have the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables set.
2. A **Hosted Zone** (Domain) is configured in your AWS account's Route53 and a **FQDN** is selected for your MostlyAI Platform installation.
3. Necessary [**Tools**](../README.md#tools) are installed in your local environment.

Finally, it would be best if you have checked the [repository guide](../README.md) for a general overview of this installation and its requirements.

## Terragrunt Stacks

Examples go through the installation in a modular way, where each collection of modules (_stack_) is responsible for a specific part of the infrastructure. We've defined the following stacks:

1. [**Infrastructure Stack**](./infrastructure-stack). This is the very base of the AWS Setup, which goes over the creation of the VPC, subnets, EKS, S3 Bucket, ACM, etc.
2. [**Helm Stack**](./helm-stack). Here we install the Helm Charts themselves - both the MostlyAI Platform and the AWS Load Balancer controller.
3. [**Post-Helm Stack**](./post-helm-stack). In the final stack, we configure the FQDN to point to the MostlyAI Platform, using the ALB's DNS name.
