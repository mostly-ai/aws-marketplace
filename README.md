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
  - [Tools](#tools)
  - [Basic Overview](#basic-overview)
  - [Installation Requirements](#installation-requirements)
  - [Getting Started](#getting-started)

## Tools

- **Required:**
  - `opentofu`: OSS fork of Terraform, used to manage the infrastructure as code. ([Source](https://github.com/opentofu/opentofu), [Install](https://opentofu.org/docs/intro/install/) & [Documentation](https://opentofu.org/docs/))
  - `terragrunt`: OpenTofu wrapper for configuration management. ([Source](https://github.com/gruntwork-io/terragrunt), [Install](https://terragrunt.gruntwork.io/docs/getting-started/install/) & [Documentation](https://terragrunt.gruntwork.io/docs/))
  - `awscli`: Command-line interface for managing AWS services. ([Source](https://github.com/aws/aws-cli/tree/v2), [Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) & [Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html))
  - `kubectl`: Command-line tool for interacting with Kubernetes clusters. ([Source](https://github.com/kubernetes/kubectl), [Install](https://kubernetes.io/docs/tasks/tools/) & [Documentation](https://kubernetes.io/docs/reference/kubectl/))
  - `helm`: Package manager for Kubernetes ([Source](https://github.com/helm/helm), [Install](https://helm.sh/docs/intro/install/) & [Documentation](https://helm.sh/docs/))
- **Recommended:**
  - `devbox`: A tool to prepare your development environment for working with this repository. ([Source/Install](https://github.com/jetify-com/devbox) & [Documentation](https://www.jetify.com/docs/devbox/))

## Basic Overview

`aws-marketplace` is a repository aimed to provide guidance on preparing your infrastructure for the MostlyAI Marketplace installation. Here, you will find a collection of Terraform modules that can be used to bootstrap the needed AWS components - VPC, EKS, ACM, etc.

Some [modules](./modules) ([eks](./modules/eks), [vpc](./modules/vpc)) are referencing widely-used [community modules](https://registry.terraform.io/namespaces/terraform-aws-modules) for the sake of brevity and ongoing support.

The repository also comes with terragrunt [examples](./examples), demonstrating how the modules above can be used.

> We believe that infrastructure should always be tailored to the specific needs of the company deploying it. As such, please note that while this repository will get you up and running, none of the modules/examples are direct requirements for the installation. Instead, treat them as a starting point for your own infrastructure setup.

## Installation Requirements

MostlyAI Platform requires the following infrastructure in place to be installed and operate correctly:

1. **Kubernetes Cluster** - the platform is distributed in a form of a helm-chart and only supports Kubernetes as a deployment target.
2. **Fully-Qualified Domain Name (FQDN)** - FQDN is required when configuring the KeyCloak identity provider realm. It is also used in the ingress configuration.
3. **TLS Certificate** - Secure Context is required for client -> platform communication starting KC26, hence the requirement for a TLS certificate.

Additionally, the [examples](./examples) in this repository assume the use/deployment of the following:

1. **AWS Load Balancer Controller** - used to manage AWS Load Balancers for the Kubernetes cluster. _Deployed as a separate helm-chart release_
2. **AWS Certificate Manager (ACM)** - used to manage TLS certificates which are automatically provisioned to ALBs. _Deployed as a separate helm-chart release_
3. **AWS EBS CSI Controller** - used to manage AWS EBS volumes for the Kubernetes cluster. _Deployed as an EKS add-on_
4. **AWS S3** - acts as a storage backend for the MostlyAI Platform. Alternatively, the `mostly-combined` chart provides an option to deploy a MinIO instance in the Kubernetes cluster.
5. **AWS Route53** - used to manage the FQDN dns record as well as the TLS certificate verification record.
6. **AWS IAM Policies && IAM Instance Roles** - additional IAM Policies are deployed along with the EKS cluster example to allow AWS Controllers to operate. These policies are attached to the IAM Instance Roles. IRSA is not used for the sake of simplicity, but is recommended for production deployments.

If you don't have an EKS cluster that matches the minimum requirements mentioned above, please refer to [this documentation](https://mostly.ai/docs/install/deploy/aws-eks) for basic guidance on how to set it up.

## Getting Started

This repository is setup with [`devbox`](https://www.jetify.com/devbox) which can be used to set up your environment. To get started, run the following command in the root of the repository, which will drop you into a shell with all the necessary tools installed:

```bash
devbox shell
```

- Remember to run `devbox init` after installation and before using it if you just installed it in your environment.
  

Otherwise, you can install the dependencies following the instructions in the **[Tools](#tools)** section above.

You will also need to have your AWS credentials available in the environment. The examples read those directly from the environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. It would also be most convenient to set the `AWS_REGION` variable to the region where you want to deploy the infrastructure for the awscli interactions.

```bash
export AWS_ACCESS_KEY_ID=your_access_key_id
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
export AWS_REGION=your_aws_region
```

Finally, we assume that you have already purchased the Marketplace offering which will automatically provide you with the access to the helm chart and images stored in the AWS Marketplace ECR repository.

With your environment set up, you can follow the instructions in the [examples](./examples) README to deploy the infrastructure or use the modules directly.
