provider "aws" {
  region = "eu-north-1"
}

terraform {
  required_version = ">=1.1.5"

  required_providers {
    flux = {
      source = "fluxcd/flux"
    }
    kind = {
      source  = "tehcyx/kind"
      version = ">=0.0.16"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
  }
}

provider "github" {
  owner = var.github_org
  token = var.github_token
}

provider "flux" {
    kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec ={
        api_version = "client.authentication.k8s.io/v1beta1"
        command     = "aws"
        args = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
  git = {
    url = "ssh://git@github.com/${var.github_org}/${github_repository.main.name}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.flux.private_key_pem
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        var.cluster_name
      ]
    }
  }
}

