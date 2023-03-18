module "terraform-aws-eks-twistlock-defender" {
  source                       = "cps-terraform.anthem.com/ACSCD/terraform-aws-eks-twistlock-defender/aws"
  version                      = "0.0.5"
  depends_on                   = [aws_eks_cluster.eks_cluster]
  cluster_name                 = var.cluster_name
  container_image              = var.td_container_image
  secret_service_parameter     = var.td_secret_service_parameter
  secret_defender_ca           = var.td_secret_defender_ca
  secret_defender_cert         = var.td_secret_defender_cert
  secret_defender_key          = var.td_secret_defender_key
  secret_admission_cert        = var.td_secret_admission_cert
  secret_admission_key         = var.td_secret_admission_key
  secret_validating_webhook_ca = var.td_secret_validating_webhook_ca
  namespace_labels             = var.twistlock_namespace_labels
}
