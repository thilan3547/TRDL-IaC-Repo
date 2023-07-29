# The Responding Dark Laughter - IaC Repo

This repo contains all the Terraform configurations required to create the AWS infrestructure for the TRDL app. Below are the list of infrastructure components created under this project.

- EKS cluster
- GitHub repo
- Bootstraping of ELS cluster with Flux (to support CI/CD functions of the TRDL)
- IAM role (which will use by an EKS service account to scan a private ECR repo)

## Architecture Diagram

image.png