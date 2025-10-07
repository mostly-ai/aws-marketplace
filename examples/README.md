---
About: Terragrunt examples for MOSTLY AI Marketplace Installation
RepositoryOwner: mostlyai-devops
DocumentationOwner: mostlyai-devops
---

# Installation Example

> This article goes over the installation process following the Terragrunt units in current directory. If you are looking for a more general installation overview, please refer to the [repository guide](../README.md) at the root of the repository.

- [Installation Example](#installation-example)
  - [Terragrunt Stacks](#terragrunt-stacks)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Post-Installation](#post-installation)

## Terragrunt Stacks

Examples go through the installation in a modular way, where each collection of modules (_stack_) is responsible for a specific part of the infrastructure. We've defined the following stacks:

1. [**Infrastructure Stack**](./infrastructure-stack). This is the very base of the AWS Setup, which goes over the creation of the VPC, subnets, EKS, S3 Bucket, ACM, etc.
2. [**Helm Stack**](./helm-stack). Here we install the Helm Charts themselves - both the MOSTLY AI Data Intelligence Platform and the AWS Load Balancer controller.
3. [**Post-Helm Stack**](./post-helm-stack). In the final stack, we configure the FQDN to point to the MOSTLY AI Data Intelligence Platform, using the ALB's DNS name.

## Prerequisites

Before you begin, ensure you have the following prerequisites in place:

1. **AWS Authentication** configured in your environment. Examples assume that you have the `AWS_ACCESS_KEY_ID`,  `AWS_SECRET_ACCESS_KEY` and `AWS_REGION` environment variables set.
2. A **Hosted Zone** (Domain) is configured in your AWS account's Route53 and a **FQDN** is selected for your MOSTLY AI Data Intelligence Platform installation. If this FQDN is part of a subdomain for which you created a separate hosted zone (e.g., mostlyai.mydomain.com under the parent domain mydomain.com), you must add an NS record in the parent domain’s hosted zone (mydomain.com) pointing to the name servers of the subdomain’s hosted zone. This ensures proper DNS resolution.
3. Necessary [**Tools**](../README.md#tools) are installed in your local environment.
4. The **IP address range** (in CIDR notation) that is allowed to access the platform. If no range is specified, the default 0.0.0.0/0 will be used, which exposes the installation to the public internet (if no other network restrictions are in place). It is strongly recommended to restrict access to trusted IP ranges only.

Finally, it would be best if you have checked the [repository guide](../README.md) for a general overview of this installation and its requirements.

## Installation

Overall, the installation process is straightforward and relies on deploying the Terragrunt stacks in the order described [above](#terragrunt-stacks). If using the examples directly, make sure to change the [common.hcl](./common.hcl) file with your own values: environment (you can create a global unique name for your organization), aws_region and hosted_zone. Also, change the [extra-locals.hcl](./extra-locals.hcl) file to define the allowed IP ranges as CIDR blocks in the format ["1.1.1.1/1","2.2.2.2/2","3.3.3.3/3"]. 

The credentials for the initial superadmin are defined in the [`helm-stack/mostly-combined/terragrunt.hcl`](./helm-stack/mostly-combined/terragrunt.hcl) file and by default are set to: `superadmin@YOURHOSTEDZONE` with a password of `defaultPassword123`. It is highly recommended to change these before proceeding with the installation.

```bash
# ! The commands below are assumed to run from the root of the repository.
# ! When running Terragrunt commands, double-check the resulting infrastructure before applying the changes. Note that some examples mock the `plan` command to enable the from-scratch previews and as such - the `apply` command is the best one to preview the changes with.

# 0. Drop into the devbox shell with the tools pre-installed
#    If not using devbox, ensure the necessary tools are installed in your environment following the README.md in the root of the repository.
devbox shell

# 1. Prepare environment
export AWS_ACCESS_KEY_ID=your_access_key_id
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
export AWS_REGION=your_aws_region

# 2. Install the Infrastructure Stack
#    -- Remember that you can always do a per-unit installation by running the `terragrunt run -- plan/apply` commands directly in the unit's directory.
# 2.1. Run the plan to preview the stack changes
#      Note that some changes will include the mock values, which will only be known during the apply stage.
#      In the examples, the creation of the GPU Node Group is disabled because by default the AWS quota for g-type instances is 0, but you can change this behavior by setting `eks_gpu_compute_node_group_enabled` to `true` in the examples/infrastructure-stack/eks/terragrunt.hcl
terragrunt run-all --working-dir examples/infrastructure-stack -- plan
# 2.2. Run the apply to create the infrastructure
#      EKS Cluster and Node Groups creation usually takes around 15 minutes.
terragrunt run-all --working-dir examples/infrastructure-stack -- apply
# 2.3. While terragrunt will check for all resources successful creation status, we need to double-check that our ACM certificate has been issued. This can be done by either:
#  - Checking the AWS Console (make sure to select the correct region):
#       https://console.aws.amazon.com/acm/home?region=us-east-1#/certificates/list
#   - Using the AWS CLI to check the certificate status
aws acm describe-certificate --certificate-arn arn:aws:acm:::certificate/your-certificate-id
# 2.4. Finally, make sure to enable the AWS License Manager in order for the installation to be able to self-issue the licenses.
# This can be done on this page:
# - https://us-east-1.console.aws.amazon.com/license-manager/home?region=us-east-1

# 3. Connect your kubectl to the created cluster using awscli. Cluster name is ${environment}-eks, where environment is defined in the common.hcl file.
aws eks update-kubeconfig --region $AWS_REGION --name mai-mplace-eks

# 4. Install the Helm Stack
# 4.1. Run the plan to preview the stack changes
#      Since MOSTLY AI is installed from the AWS Marketplace Helm Registry, you will need to provide the authentication to it. This is done in the example via AWS_ECR_AUTH_TOKEN environment variable.
export AWS_ECR_AUTH_TOKEN=$(aws ecr get-login-password --region us-east-1)
terragrunt run-all --queue-include-external --working-dir examples/helm-stack -- plan
# 4.2. Run the apply to generate the values.yaml file required for the helm installation
terragrunt run-all --queue-include-external --working-dir examples/helm-stack -- apply
# 4.3. Locate values.yaml and save it to VALUES_FILE_PATH 
export VALUES_FILE_PATH=$(find examples/helm-stack/mostly-combined/ -type f -path "*values.yaml")
# 4.4.  Get the latest version from https://github.com/mostly-ai/mostlyai/releases
# 4.5. Replace the [version] with the one retrieved in the previous step and run the install of the MOSTLY AI Data Intelligence Platform
helm upgrade --install mostly-ai oci://709825985650.dkr.ecr.us-east-1.amazonaws.com/mostly-ai/platform/mostly-combined/[version] \
  --values $VALUES_FILE_PATH \
  --namespace mostlyai

# 5. Install the Post-Helm Stack.
# 5.1. Fetch the ALB DNS name from the Ingress resource's status field.
export AWS_ALB_DNS_NAME=$(kubectl get ingress -n mostlyai -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
# 5.2. Run the plan to preview the stack changes
terragrunt run-all --working-dir examples/post-helm-stack -- plan
# 5.3. Run the apply to configure the FQDN to point to the MOSTLY AI Data Intelligence Platform
terragrunt run-all --working-dir examples/post-helm-stack -- apply
```

## Post-Installation

Once the installation is complete, you can access the Platform using the FQDN you configured. This is a great time to check that the installation was successful and that the MostlyAI Platform is up and running.

First, you should run a smoke test to verify the installation. This will verify that all the components are working correctly, able to communicate, that the backend storage/database is configured correctly and, finally, that the compute jobs are able to schedule. For this, it's best to follow the guide on the [MostlyAI Platform Documentation](https://mostly.ai/docs/quick-start/model-creators) page.

Once you have verified the installation, it's great to proceed with enabling MostlyAI assistant following the [assistant configuration guide](https://mostly.ai/docs/assistant/configuration).

Finally, you can setup the MostlyAI Platform with different computes to support your workloads, by following the [compute configuration guide](https://mostly.ai/docs/administration/compute).

## Frequently Asked Questions

### Question: Can I change the allowed IP range after the installation?
Yes. You can update the Helm chart configuration and then re-apply the charts to apply the new IP range. 

### Question: I want to install the platform on an AWS account where a local network and/or VPN is already configured. Can I use this VPC instead of creating a new one?
Yes, you can configure the platform to use an existing VPC. To do this, update the [terragrunt.hcl](./infrastructure-stack/eks/terragrunt.hcl) file with the appropriate values for `vpc_id`, `private_subnet_ids`, and `public_subnet_ids` in the `inputs` section before starting the installation. You also need to make sure that you remove the VPC creation parts from the scripts. 
