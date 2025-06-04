---
About: Installing MostlyAI AWS Marketplace Offering
RepositoryOwner: mostlyai-devops
DocumentationOwner: mostlyai-devops
---

# MostlyAI Marketplace Installation Guide

[![Website](https://img.shields.io/badge/Website-text?style=flat-square&color=f2f4ff)](https://mostly.ai/)
[![Product Documentation](https://img.shields.io/badge/Product%20Documentation-text?style=flat-square&color=6fa8dc)](https://mostly.ai/docs)
[![AWS Marketplace Offering](https://img.shields.io/badge/AWS%20Marketplace%20Offering-text?style=flat-square&color=ff9900)](https://aws.amazon.com/marketplace/pp/prodview-clqfgzfzznfoc)

- [MostlyAI Marketplace Installation Guide](#mostlyai-marketplace-installation-guide)
  - [Tools and Extensions](#tools-and-extensions)
  - [Basic Overview](#basic-overview)
  - [Installation Requirements](#installation-requirements)
  - [Getting Started](#getting-started)

## Tools
- **Required:**
  - `opentofu`: OSS fork of Terraform, used to manage the infrastructure as code. ([Source](https://github.com/opentofu/opentofu), [Install](https://opentofu.org/docs/intro/install/) &  [Documentation](https://opentofu.org/docs/))
  - `terragrunt`: OpenTofu wrapper for configuration management. ([Source](https://github.com/gruntwork-io/terragrunt),  [Install](https://terragrunt.gruntwork.io/docs/getting-started/install/) & [Documentation](https://terragrunt.gruntwork.io/docs/))
- **Recommended:**
  - `devbox`: A tool to prepare your development environment for working with this repository. ([Source/Install](https://github.com/jetify-com/devbox) & [Documentation](https://www.jetify.com/docs/devbox/))

## Basic Overview

`aws-marketplace` is a repository aimed to provide guidance on preparing your infrastructure for the MostlyAI Marketplace installation. Here, you will find a collection of Terraform modules that can be used to bootstrap the needed AWS components - VPC, EKS, ACM, etc.

Some [modules](./modules) ([eks](./modules/eks), [vpc](./modules/vpc)) are referencing widely-used [community modules](https://registry.terraform.io/namespaces/terraform-aws-modules) for the sake of brevity and ongoing support.

The repository also comes with terragrunt [examples](./examples), demonstrating how the modules above can be used.

> We believe that infrastructure should always be tailored to the specific needs of the company deploying it. As such, please note that while this repository will get you up and running, none of the modules/examples are direct requirements for the installation. Instead, treat them as a starting point for your own infrastructure setup.

## Installation Requirements

MostlyAI Platform qequires the following infrastructure in place to be installed and operate correctly:

1. **Kubernetes Cluster** - the platform is distributed in a form of a helm-chart and only supports Kubernetes as a deployment target.
2. **Fully-Qualified Domain Name (FQDN)** - FQDN is required when configuring the KeyCloak identity provider realm. It is also used in the ingress configuration.
3. **TLS Certificate** - Secure Context is required for client -> platform communication starting KC26, hence the requirement for a TLS certificate.

## Getting Started

This repository is setup with [`devbox`](https://www.jetify.com/devbox) which can be used to set up your environment. To get started, run the following command in the root of the repository, which will drop you into a shell with all the necessary tools installed:

```bash
devbox shell
```

Otherwise, you can install the dependencies following the instructions in the **[Tools](#tools)** section above.

You will also need to have your AWS credentials available in the environment. The examples read those directly from the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

```bash
export AWS_ACCESS_KEY_ID=your_access_key_id
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
```

With your environment set up, you can follow the instructions in the [examples](./examples) README to deploy the infrastructure or use the modules directly.
