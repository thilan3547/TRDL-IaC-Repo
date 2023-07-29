# The Responding Dark Laughter - IaC Repo

This repo contains all the Terraform configurations required to create the AWS infrestructure for the TRDL app. Below are the list of infrastructure components created under this project.

- EKS cluster
- GitHub repo
- Bootstraping of ELS cluster with Flux (to support CI/CD functions of the TRDL app)
- IAM role (which will use by an EKS service-account to scan a private ECR repo)

## Architecture Diagram

image.png

## High Availability

In order to make sure the TRDL app maintaines high availability,

- EKS cluster is setup across 2 AZs
- EKS cluster is configured with a EKS managed node group of min, max and desired node settings
- TRDL app is deployed in 2 pods across 2 nodes (initial version)

## CICD

From a developer releasing a new version of the TRDL app to provissioning pods with the new version, all the steps are automated and managed by Flux. The Flux repository which contains the flux components as well as manifest files related to the pods, services and ingress can be found at https://github.com/thilan3547/fluxcd-demo-3.

## Log Management

Below log types are enable at the EKS cluster with a CloudWatch log retension period of 7 days.
- audit
- api
- authenticator
- controllerManager
- scheduler

## TRDL app

Please refer https://github.com/thilan3547/sinch-app for the TRDL app. A GitActions workflow is in place to build the docker image and update to a private ECR repo.

### Prerequisites

Below components are required to run the project locally,
- GitHub account
- GitHub token
- AWS account and ECR private repo
- Terrafrom installed

### Terraform Plan and Apply

- terraform plan -var "github_org=<git user>" -var "<git token>"
- terraform apply -var "github_org=<git user>" -var "<git token>"

### Install the TRDL app components

After completing the Terraform instalation, add all the yaml files inside https://github.com/thilan3547/fluxcd-demo-3 -> clusters -> my-cluster -> demo to the new GitHub repository created by Terraform.

Update ecrpolicy.yaml, ecrscan.yaml, imageupdateautomation.yaml and sinchpods.yaml files with the ECR url and docker tag pattern.

## Future Improvements

- Migrate the Terraform state from local to S3 with DynamoDB checksom
- Use a user friendly FQDN as the customer accessing URL
- Use HTTPS endpoint with an ACM certificate
