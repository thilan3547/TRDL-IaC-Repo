module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = var.cluster_name 
  cluster_version = "1.27"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  cluster_enabled_log_types = [ "audit", "api", "authenticator" , "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = "7"

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  eks_managed_node_group_defaults = {
    disk_size = 150
  }

  eks_managed_node_groups = {
    general = {
      desired_size = 2
      min_size     = 2
      max_size     = 10

      labels = {
        role = "general"
      }

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "staging"
  }
}

#Cluster addons
module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.2" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_aws_load_balancer_controller    = true
}


#GIT
resource "github_repository" "main" {
  name       = var.repository_name
  visibility = var.repository_visibility
  auto_init  = true
}

resource "github_branch_default" "main" {
  repository = github_repository.main.name
  branch     = var.branch
}

resource "tls_private_key" "flux" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "Flux"
  repository = github_repository.main.name
  key        = tls_private_key.flux.public_key_openssh
  read_only  = "false"
}

#Flux bootstraping
resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this]
  path = "clusters/my-cluster"
  components_extra = ["image-reflector-controller","image-automation-controller"]
}

#IAM role for ECR scaning - service account image-reflector-controller
resource "aws_iam_role" "eks-scan-ecr" {
  name = "EKS-scan-ECR"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::746247950449:oidc-provider/oidc.eks.eu-north-1.amazonaws.com/id/${trimprefix(module.eks.cluster_oidc_issuer_url, "https://oidc.eks.eu-north-1.amazonaws.com/id/")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
            "StringEquals" = {
                "oidc.eks.eu-north-1.amazonaws.com/id/${trimprefix(module.eks.cluster_oidc_issuer_url, "https://oidc.eks.eu-north-1.amazonaws.com/id/")}:sub": "system:serviceaccount:flux-system:ecr-credentials-sync"
                "oidc.eks.eu-north-1.amazonaws.com/id/${trimprefix(module.eks.cluster_oidc_issuer_url, "https://oidc.eks.eu-north-1.amazonaws.com/id/")}:aud": "sts.amazonaws.com"
            }
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecr_readonly_policy_attachment" {
  name = "Policy Attachement"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  roles       = [aws_iam_role.eks-scan-ecr.name]
}