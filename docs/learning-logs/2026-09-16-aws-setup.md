# AWS Setup & Terraform Bootstrap

## 1. AWS Account Setup

* Created a new AWS account.
* Enabled MFA/2FA for the AWS root user.
* Configured **IAM Identity Center**.
* Created an `Admin` group in IAM Identity Center.
* Created an `AdministratorAccess` permission set.
* Created an IAM Identity Center user and assigned the user to the `Admin` group.
* Logged out of the root account.
* Logged in using the Admin Identity Center user.

> **Note:** The Admin user is used for the initial Terraform/bootstrap setup. The goal is to eventually use a lower-privilege DevOps user for day-to-day infrastructure work.

---

## 2. AWS CLI Installation

Followed the official AWS CLI installation documentation:

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Installed AWS CLI on macOS:

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"

sudo installer -pkg AWSCLIV2.pkg -target /
```

Verified the installation:

```bash
which aws
aws --version
```

Updated AWS CLI as required.

---

## 3. AWS CLI — IAM Identity Center / SSO

Followed the official AWS documentation:

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html

Configured AWS CLI with IAM Identity Center:

```bash
aws configure sso
```

Configured an SSO session and created a local CLI profile named:

```text
admin
```

Logged in:

```bash
aws sso login --profile admin
```

Verified the authenticated AWS identity:

```bash
aws sts get-caller-identity --profile admin
```

### What I learned

The AWS CLI profile name is a **local configuration name**. It does not have to match the name of the AWS/IAM Identity Center user.

For example:

```bash
--profile admin
```

tells the AWS CLI to use the credentials/configuration stored under the local `admin` profile.

---

## 4. Terraform Installation

Installed Terraform using Homebrew:

```bash
brew tap hashicorp/tap

brew install hashicorp/tap/terraform
```

Updated Homebrew and Terraform:

```bash
brew update

brew upgrade terraform
```

Verified the installation:

```bash
terraform version
```

---

## 5. Terraform Project Setup

Created the Terraform bootstrap directory inside the AWS infrastructure repository:

```bash
cd ~/dev/aws-infrastructure

mkdir -p bootstrap

cd bootstrap

touch main.tf
```

The purpose of `bootstrap` is to contain the initial Terraform configuration required to set up/manage AWS identity and access.

---

## 6. Terraform AWS Provider

Configured the AWS provider using the official HashiCorp AWS provider documentation:

https://registry.terraform.io/providers/hashicorp/aws/latest/docs

The initial provider uses:

* Region: `eu-west-1`
* AWS CLI profile: `admin`

```hcl
provider "aws" {
  region  = "eu-west-1"
  profile = "admin"
}
```

### Why `profile = "admin"`?

Terraform uses the AWS provider to communicate with AWS.

The `profile` tells Terraform to use the AWS CLI credentials/configuration stored under the local `admin` profile.

This means Terraform does not need AWS access keys written directly into the Terraform configuration.

---

## 7. Terraform Initialization

Initialized the Terraform working directory:

```bash
terraform init
```

Terraform downloaded the required AWS provider and created the local `.terraform/` directory and `.terraform.lock.hcl`.

### Git configuration

The `.terraform/` directory is ignored using `.gitignore`:

```gitignore
.terraform/
```

The `.terraform.lock.hcl` file is committed because it records the provider versions selected by Terraform.

---

## 8. Terraform Authentication Test

Tested the configuration with:

```bash
terraform plan
```

Terraform successfully authenticated with AWS and reported that the infrastructure matched the current configuration.

At this point, Terraform had not created or modified any AWS resources.

---

## 9. AWS Regions

The infrastructure and IAM Identity Center are currently in different AWS regions:

| Purpose             | Region       |
| ------------------- | ------------ |
| Infrastructure      | `eu-west-1`  |
| IAM Identity Center | `eu-north-1` |

`eu-west-1` will be used for the infrastructure labs, including resources such as VPC, EC2, S3, CloudWatch and SNS.

IAM Identity Center is currently configured in `eu-north-1`.

Because of this, Terraform uses a second AWS provider configuration with an alias:

```hcl
provider "aws" {
  region  = "eu-north-1"
  profile = "admin"
  alias   = "sso"
}
```

The `sso` alias allows Terraform resources that belong to IAM Identity Center to explicitly use the `eu-north-1` provider while the normal infrastructure resources continue using `eu-west-1`.

---

## 10. IAM Identity Center Discovery

Used the AWS CLI to discover the IAM Identity Center instance:

```bash
aws sso-admin list-instances --profile admin --region eu-north-1
```

This returned the Identity Center:

* Instance ARN
* Identity Store ID
* Primary region
* Account ID
* Status

The Instance ARN and Identity Store ID will be used by Terraform when managing IAM Identity Center resources.

---

## 11. Git Workflow

Committed the Terraform bootstrap configuration to the Git repository.

The workflow used was:

```bash
git status
git add .
git commit -m "Add Terraform bootstrap configuration"
git push
```

Verified the repository was clean:

```bash
git status
```

Result:

```text
nothing to commit, working tree clean
```

---

# Current State

At this point:

* AWS account is configured.
* Root MFA is enabled.
* IAM Identity Center is configured.
* An Admin user is available.
* AWS CLI is installed and authenticated through SSO.
* Terraform is installed.
* Terraform successfully authenticates using the AWS CLI `admin` profile.
* Terraform is configured for `eu-west-1`.
* A second aliased Terraform provider is configured for IAM Identity Center in `eu-north-1`.
* The Terraform bootstrap configuration is committed to GitHub.

## Next

The next step is to use Terraform to retrieve the IAM Identity Center instance information and then begin creating the lower-privilege DevOps user/group/permission structure.

The goal is to keep the infrastructure and IAM configuration reproducible through Terraform rather than manually creating resources through the AWS Console.
