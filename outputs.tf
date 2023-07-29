output "endpoint" {
  value = trimprefix(module.eks.cluster_oidc_issuer_url, "https://oidc.eks.eu-north-1.amazonaws.com/id/")
}