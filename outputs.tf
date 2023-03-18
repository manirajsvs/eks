output "cluster_id" {
  value       = aws_eks_cluster.eks_cluster.id
  description = "The name of the cluster."
}

output "cluster_arn" {
  value       = aws_eks_cluster.eks_cluster.arn
  description = "The Amazon Resource Name (ARN) of the cluster."
}

output "kubeconfig-certificate-authority-data" {
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  description = "The base64 encoded certificate data required to communicate with your cluster."
}

output "endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "The endpoint for your Kubernetes API server."
}

output "identity" {
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  description = "Issuer URL for the OpenID Connect identity provider."
}


output "platform_version" {
  value       = aws_eks_cluster.eks_cluster.platform_version
  description = "The platform version for the cluster."
}

output "status" {
  value       = aws_eks_cluster.eks_cluster.status
  description = "The status of the EKS cluster. One of CREATING, ACTIVE, DELETING, FAILED."
}

output "version" {
  value       = aws_eks_cluster.eks_cluster.version
  description = "The Kubernetes server version for the cluster."
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  description = "The cluster security group that was created by Amazon EKS for the cluster."
}

output "vpc_id" {
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].vpc_id
  description = "The VPC associated with your cluster."
}

output "custom_security_group_id" {
  value       = aws_security_group.security-group-cluster.id
  description = "Security group created for EKS cluster creation"
}

output "openID_URL" {
  value       = aws_iam_openid_connect_provider.oidc_provider.url
  description = "The URL of the identity provider."
}

output "cluster_role_arn" {
  value       = aws_iam_role.iamrole.arn
  description = "The Amazon Resource Name (ARN) specifying the cluster role."
}

output "cluster_role_name" {
  value       = aws_iam_role.iamrole.name
  description = "The name of the cluster role."
}