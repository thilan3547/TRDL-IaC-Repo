variable "github_token" {
  sensitive = true
  type      = string
}

variable "github_org" {
  type = string
}

variable "cluster_name"{
  type = string
  default = "my-eks"
}

variable "repository_name"{
  type = string
  default = "fluxcd-demo-3"
}

variable "repository_visibility"{
  type = string
  default = "private"
}

variable "branch"{
  type = string
  default = "main"
}