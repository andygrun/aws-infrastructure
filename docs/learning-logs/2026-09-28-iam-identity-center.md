# IAM Identity Center — Terraform Management

**Period:** September 16–28, 2026

## 1. Project Objective

Continue building the AWS infrastructure learning project using Terraform for Infrastructure as Code (IaC).

The objective is to manage IAM Identity Center resources through Terraform, establish a lower-privilege DevOps identity structure, and learn how Terraform tracks and manages AWS resources.

The project prioritizes:

* Terraform-managed infrastructure rather than manual console configuration.
* Least-privilege access.
* Understanding Terraform resources, data sources, providers, and state.
* Documenting decisions, troubleshooting, and lessons learned.

## 2. Existing Terraform Bootstrap

Continued working in the `bootstrap/` directory of the `aws-infrastructure` repository.

The configuration includes:

* An AWS provider for infrastructure in `eu-west-1`.
* An aliased AWS provider, `aws.sso`, for IAM Identity Center in `eu-north-1`.
* The `aws_ssoadmin_instances` data source to discover the existing Identity Center instance.
* Outputs for the Identity Center instance ARN and Identity Store ID.

The AWS CLI uses the local `admin` profile for authentication.

### What I learned

AWS resources can belong to different regions. Terraform provider aliases allow resources and data sources to use the correct regional configuration.

The `provider = aws.sso` argument explicitly selects the aliased provider.

## 3. Creating the DevOps Group

Followed the official Terraform AWS provider documentation for the `aws_identitystore_group` resource.

Created the `DevOps` group through Terraform.

The resource uses:

* The Identity Store ID discovered through the data source.
* The display name `DevOps`.
* A description identifying it as a Terraform-managed DevOps team group.
* The aliased `aws.sso` provider.

### Troubleshooting

The first apply attempt failed because the resource was using the default provider in `eu-west-1`, while IAM Identity Center was configured in `eu-north-1`.

Adding `provider = aws.sso` directed the resource to the correct region.

The group was successfully created and verified in AWS and Terraform state.

### What I learned

Terraform resources can reference data source attributes directly, avoiding hardcoded identifiers.

Provider selection is important when managing services configured in a different region from the main infrastructure.

## 4. Creating the DevOps User

Followed the official Terraform AWS provider documentation for the `aws_identitystore_user` resource.

Created an Identity Center user with the username `andydev` and display name `Andy Dev`.

Configured the user's given name, family name, and email address.

The resource uses the discovered Identity Store ID and the `aws.sso` provider.

### Primary email

Initially, the email address was not marked as primary.

After reviewing the plan, changed the email configuration to `primary = true`.

The resource was then successfully applied.

### What I learned

Terraform plans show the proposed resource attributes before changes are applied.

The `primary` attribute identifies the user's primary email address in the Identity Store.

## 5. Terraform State and Verification

Used Terraform commands to verify the configuration and resource state:

```bash
terraform fmt
terraform plan
terraform apply
terraform state list
terraform show
```

### What I learned

* `terraform fmt` formats Terraform configuration.
* `terraform plan` previews proposed changes.
* `terraform apply` applies the configuration.
* `terraform state list` lists resources tracked in the current state.
* `terraform show` displays the current state or a plan.

Terraform state tracks the resources managed by the configuration. The configuration describes the desired infrastructure, while the state helps Terraform determine what changes are required.

## 6. Git Workflow

Used Git to review and commit Terraform configuration changes.

Commands used during the workflow included:

```bash
git status
git diff
git diff --check
git add
git commit
git push
```

The DevOps group resource was committed with:

```text
Created DevOps group using terraform
```

The DevOps user resource was created and applied successfully. Its commit status should be verified before the next step.

### What I learned

Reviewing changes before committing helps identify unintended modifications.

Terraform state files remain excluded from Git, while the Terraform configuration and provider lock file are tracked.

## 7. Current Infrastructure State

The Terraform bootstrap configuration now includes:

* AWS provider for `eu-west-1`.
* Aliased AWS provider for `eu-north-1`.
* IAM Identity Center discovery through a data source.
* A Terraform-managed `DevOps` group.
* A Terraform-managed Identity Center user named `andydev`.

The group and user have been successfully created through Terraform.

## 8. Next Steps

The next planned step is to create a group membership resource using `aws_identitystore_group_membership`.

This will associate the `andydev` user with the `DevOps` group.

After membership is established, the project will continue toward permission-set configuration and assignment, with the goal of establishing a lower-privilege identity for day-to-day infrastructure work.

All changes should continue to be managed and documented through Terraform wherever possible.
