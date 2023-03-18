#Required parameters
variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "master_user" {
  description = "IAM Role name of the user who will be the administrator of the EKS Cluster"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
}

#Optional parameters
variable "vpc_id" {
  description = "VPC ID to attached the security group"
  type        = string
  default     = null
}

variable "cluster_enabled_log_types" {
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "Default is []. A list of the desired control plane logging to enable. valid list is [\"api\", \"audit\", \"authenticator\", \"controllerManager\", \"scheduler\"]."
  type        = list(any)
}

variable "cluster_version" {
  description = "Default is \"\". Desired Kubernetes master version. If you do not specify a value, the latest available version at resource creation is used and no upgrades will occur except those automatically triggered by EKS. The value must be configured and increased to upgrade the version when desired. Downgrades are not supported by EKS."
  type        = string
  default     = ""
}

variable "cluster_log_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
  default     = 90
}

variable "cluster_create_timeout" {
  description = "Default is 30m. Timeout value when creating the EKS cluster."
  type        = string
  default     = "30m"
}

variable "cluster_delete_timeout" {
  description = "Default is 15m. Timeout value when deleting the EKS cluster."
  type        = string
  default     = "15m"
}

variable "namespace" {
  type        = string
  description = "Default is kube-system. Namespace defines the space within which name of the config map must be unique."
  default     = "kube-system"
}

variable "config_map_name" {
  type        = string
  description = "Default is aws-auth. Name of the config map, must be unique. Cannot be updated."
  default     = "aws-auth"
}

variable "additional_roles" {
  description = "Additional IAM roles to add to `config-map-aws-auth` ConfigMap"

  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}

variable "cluster_log_kms_key_id" {
  description = "Cluster Cloudwatch KMS Key ID"
  default     = ""
}

variable "cluster_kms_key_id" {
  description = "Cluster EC2 KMS Key ID"
  default     = ""
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "Set of exclusive IAM managed policy ARNs to attach to the IAM role. If this attribute is not configured, Terraform will ignore policy attachments to this resource. When configured, Terraform will align the role's managed policy attachments with this set by attaching or detaching managed policies. Configuring an empty set (i.e., managed_policy_arns = []) will cause Terraform to remove all managed policy attachments."
  default     = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}


variable "subnet_ids" {
  type        = list(string)
  description = "Identifiers of EC2 Subnets to associate with the EKS Node Group. These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER_NAME (where CLUSTER_NAME is replaced with the name of the EKS Cluster)."
  default     = null
}

variable "assume_role_policy" {
  type        = string
  description = "The policy that grants an entity permission to assume the role. User need to provide the assume role policy in json file format."
  default     = null
}

variable "assume_role_service_names" {
  type        = list(string)
  description = "Required list of services to create the assume role trust relationship."
  default     = ["eks.amazonaws.com"]
}

variable "role_arn" {
  type = string
  description = " ARN of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf. Ensure the resource configuration includes explicit dependencies on the IAM Role permissions by adding depends_on if using the aws_iam_role_policy resource or aws_iam_role_policy_attachment resource, otherwise EKS cannot delete EKS managed EC2 infrastructure such as Security Groups on EKS Cluster deletion."
  default = null
}

##### Twistlock-defender Agent variables
variable "td_container_image" {
  type        = string
  description = "Image used for twistlock defender agent"
  default     = "quay.apps.lz-np2.ent-ocp4-useast1.aws.internal.das/cnas/twistlockimages:defender_22_01_880"
}

variable "td_secret_service_parameter" {
  type        = string
  default     = "RFJ1ODBQc0hBNjJlR1ZpQU5IRm1zOGlNQWJ0NEM0L1AyM29TeWQyaUxZcTJKNUEyU01UUWNmQWR3b2QwZGRKVU1neHpLZmk5NlRlYlF4ODI4TFEyZHc9PQ=="
}

variable "td_secret_defender_ca" {
  type        = string
  default     = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURIVENDQWdXZ0F3SUJBZ0lSQU9FdkU0WWRIN3dkeU1SWUZJSlFuMll3RFFZSktvWklodmNOQVFFTEJRQXcKS0RFU01CQUdBMVVFQ2hNSlZIZHBjM1JzYjJOck1SSXdFQVlEVlFRREV3bFVkMmx6ZEd4dlkyc3dIaGNOTWpJdwpNakkzTURneE9EQXdXaGNOTWpVd01qSTJNRGd4T0RBd1dqQW9NUkl3RUFZRFZRUUtFd2xVZDJsemRHeHZZMnN4CkVqQVFCZ05WQkFNVENWUjNhWE4wYkc5amF6Q0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0MKZ2dFQkFOb1lNY3BJZWNCMjF6S29qTWdRRDV2RjIvNEd0K1FaeVVJRWZaTEFHU0lBVEwydXJLNC8wbUUrU0lVWApRSWtxVUNmVEw1TXQzNmc1VU9rRUp1eWJFYng5NkRlODJhQnhyNGJiVXh4aCtlWS9WQm0weTNaSHpmMWE5M0NtCm1xcVZ0VytTQXl5S1FGWWpsRlZKMHRha2U3TlNDUVQvL3hVVmQzZ3ROY1ZPMWhISzFHU2w1c04vbGtYcHdmS3QKRit4UDE0dmord1pGR1JGRnJpOXFmYWNLTkdsVnNRTGdFbExBZjJmdGRjRlFMRWFlcDh6UlR5U2NrRmhGN1gxRAo5SXNUOHpBYnVMdzA2M3F0Z0hrWi9malAvU0xreGxWSkE4ajJiSTRrbVpER08yQ1dlSjJyOVpwcDNFTmNnb3FECmllVzlqdFRuTEs5Qk9IbkthQjV6cUloUHNOOENBd0VBQWFOQ01FQXdEZ1lEVlIwUEFRSC9CQVFEQWdLc01BOEcKQTFVZEV3RUIvd1FGTUFNQkFmOHdIUVlEVlIwT0JCWUVGTjBMcmx3TStDWHJFWjllWlBGeTNYakN0YnlZTUEwRwpDU3FHU0liM0RRRUJDd1VBQTRJQkFRQktxVXlkRjNoNVlaOGQxZjRCN1JiNDFLVnVVeDJJUjNaci9naHhpa1ZwCjZUVm81bTBOZHA2NE40Y0pPN2Vkc0J5M0RHU0RVeGo1ZjNZaUs0ZUVQNnlLanNqd2FvdlIyTmVQdW5oMlFiSmcKOEdxUTNEaksvWlo5TCt3Ykw5TWZhODhBQzBja0MzMDVhM3hIb1RCSGlPOU5ZZk1UcXJMZFVod0NPOTgrSHoxUApjL3VFUk5VQ2o5YnR4NEk5aVlleTI0TGxMeWZxVzlzQUtEZkQrbFJZL2o3bnYyYW1COHl1RlRFbThwUUMyQ1FyCmlYTGJrWWxQb0IraElpR0Z1cXoxTWxFK3Z3STFxblVpb1g4R0ZXd1JEdkJTTmpGSjkrQ2E1TCtsZXl1OUd0U2sKUHlQU0w2L054S0xSUDd5d2ZzeGxwWWY5VE96WFE2Z3hxMG1BYVlFU3A2ZnkKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
}

variable "td_secret_defender_cert" {
  type        = string
  default     = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURQRENDQWlTZ0F3SUJBZ0lSQU9KWC84RXB1d0l6VG1hWFd6SWJGZUl3RFFZSktvWklodmNOQVFFTEJRQXcKS0RFU01CQUdBMVVFQ2hNSlZIZHBjM1JzYjJOck1SSXdFQVlEVlFRREV3bFVkMmx6ZEd4dlkyc3dIaGNOTWpJdwpNekkzTVRReE1qQXdXaGNOTWpVd016STJNVFF4TWpBd1dqQW9NUkl3RUFZRFZRUUtFd2xVZDJsemRHeHZZMnN4CkVqQVFCZ05WQkFNVENXeHZZMkZzYUc5emREQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0MKZ2dFQkFOODdhRzdTSlpjTjJlOXdMTnJKTEFDNDRvOFFDR3BWNFhzZndMc3ZIRVRQTWY3cGZpU2dCai9qZDVOdgp0cndEa0VEZUJIdFFpVTk0VkUxT0hMblhUaGJaUUxtWEtEeTAzUFpLWUw4WmNNdWtwSy9zd2lFcno4OG9uZW9ZCmIxMHdpWGhTVEQ3aldnSWVpclJGWURJU2lIOWZKTGY5anhWeitZTlI2R1U2L2xoaFFleDBkY1BZWGRzWWVkaVIKZ0FSN0J4UXlwU2N3MHJDd0Y1Nk9ZU2FPZ3RUdlozajJJK1g2Rm1adUxZNW9PbHo1UDc0ODRQd1ZxYitlNXVvVQp2NDZDWkpUYmg1cS9IbmZ3Q05NZ3VVWkczYVM5ZUkyaWRFM2dGUXBPelZOdzl5VE5Nb0xjVmlSRXdEV29jWXBiCmV5TVAvTE8xbWRmZ1kxeUZadzU4bWNUQlZFTUNBd0VBQWFOaE1GOHdEZ1lEVlIwUEFRSC9CQVFEQWdlQU1CTUcKQTFVZEpRUU1NQW9HQ0NzR0FRVUZCd01DTUF3R0ExVWRFd0VCL3dRQ01BQXdId1lEVlIwakJCZ3dGb0FVM1F1dQpYQXo0SmVzUm4xNWs4WExkZU1LMXZKZ3dDUVlGS2dRQkFnY0VBREFOQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBCldqQWtQTkZseFBOWnVuV1VCbEdiUHQwWVQ3ZEN1RGxDSWdsTTVOVCtDSTJBRTlKdjE0ZDhVN3Q2VDYyT3Bma3IKNVdBa3JHS01PTlJLNnZPNldLSEhyWTYvZlhmMlo2aGo3anpqM3JXbjVjbjM0VW84NW5OK1UxSk5acXdaVmdvbAp2UXp1WStwVG51QzRnQTZ2M1pONEtMUjVzK3JuNzhxQS9hU3QrZGtPVWYwd3A3NkdXcEJyaEpoTmVsbkxzRG53CllsY1o4RVE3NUVRR0w5TDNHY3liUGJwUmdQQjVwdEVpYkVOOG1uTFdpUHYwMGp6K0FDSFZ0WW1ZY1gwbm04SzMKNVVCVVFYREVQVkpRQUs1eThBWUpyWDBQeVN6RVpmSWtwcjcvamVLL2trbFpaVmliUCtqOVdHRm1tQmp3d0swYQpVTTRFTDRMVC84TGxoTmZpeUZOdlJRPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
}

variable "td_secret_defender_key" {
  type        = string
  default     = "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpQcm9jLVR5cGU6IDQsRU5DUllQVEVECkRFSy1JbmZvOiBBRVMtMjU2LUNCQyxlMWI2NDc5MzdmM2I0NzNjNmUyNWExNzc0ZmNjNDBiMQoKNVhGVkJHUXp6UVkvWEpSUDBOUGVzTG9adGo2eXZnS05DSTAwd3FuMVpxOWhEaVovd2R4QVBrbVdXWGljdjF4TQpQMVJYTFRVQjU3TXNkck1qT0c0WFVtL0l0UE82NTBRSFY1UFlUT2VBZ0pzSTVXVUJyWUF3SWQ4YmUvMCtJWE0vCmUyYldEYVpDMHQwc1pVRG0wakdsdC8veG80SEpwbXEwUDlXTnM3Qjl1U290S0N5WVMvZVpKR1orSWtrVVpQcHIKUDZPeGlxeXdpczAyQmh3YTRXVVZjRTFQYmNucit3d3VLK0NWN1JkSjVaS2FqZjV4WmNXclkwejF0UUYyUTJNNAoxcG9Wc1NUNTkxcFhtOXBiRy8xM28vR1M5bUhuNHlFNmpxZmNabGZud05zVlQyWVNIOEx5TFM2UXhKQnVwcStqCk9YazU2anVFeUhxTS9vRzNNZlNKamZPcUIxK2luTXA4NG5LZ1Y1U0p6dU9ZdElVeUxCaG1aKzZqYzl2OFNzNkwKS283eDhLYTNVZU53ZWVpNFRhbUk4YzA4R0dQRDRDV2NUbXQ5VHk5WmI4dmJjVWNxLzlaeWcwVE96Yjh6eUpLOApFUU8rZGh6dndWRndxL1pYNlZwVnVXZVlSUFdZbWJld2JmcVZXdnc4TVBRa3JCUlh3N3d6aXJ1ZGdZSU1vQ3NQCnpKcGdFSWcxM082cTFUWFdtSW5hclBsdlJLVVBmdXRCWDgwTXZUVjBicFdXZWszY1J1U1V5MW9paEZlODQzcWgKQlhibjVpS3BYaFd6bGFzSGJZcVk1U09LbmNtNmNhUU1xZ1ZQdDVueHYwNjczVEtPeUF5em9FekYyaHVBeVM5VQp0SGpWUW5MelNIQkJCcnNBemRxL05jWWluQ2QyTmdHM1ZNeGZoVDZ4dFZFNXdpVEI0OVZJazUwUkhmRURXM1djCk5PQ093Mk11UzVQbVFQc0FaWVNiVGhTY0pZS0ROb3BDWHFoZVN2NTFyNHYwNjA3K0ZweHRSdWgxYU4vaHF3QkwKbEZ1Z1YzM2dLWS9KWjhqWk5vQjFKaTM3NG9XTUYrL3J2ZWEzdVNJbjdra2lvU1I1SytaT1lFZDlHNDZlTW9xMAowdTRyZjNqVDdITEFiWmwrTzg0bEtLR3lxdWwrVjROd05sV0JOL1BWenJhbHB3NFVManZRQlVjVVBQZllmVHlsCkt5Y09lcThPNW9GZng1YlFhNGk1YTAyRFNzN1JPL2xOK09YK2lXZ1hHeDh0eFlmeExRT3YvWFFEbU5pUlFWc2gKV2hqVUc4dTNCM2FndjNiZG4yS2hESVZqNDBvMEdCV0V6UHk4QVZoM1QrNW9xRU1SMWFDUXhzbTc1dGRIMG5VOQpNS3p4MzZNUnVyZE1ObzVYS2JIZVM5UWdiWCsyYWFvYlNHWURDOUxZeWVDRXJid0xnQVRtemg0SzlMRkpCNk14Ck1EMXFrRXlZWEpnekVtLzJPdS9VYUJnem00ZEhXcThTdUIzaGI0TW40ZmoxcEw4eWp1VFVXdzl3UWVKMjlBbmUKNEpjWnIxdFlMS1YvcjdTWUsrNWJ6T1Q3S2pwSmMxQnNZSFV4czZWUFNVR1pBNlo2RWNza0dvQ2M0K3BCZ1o1awp3Zk9DSnZWR2hEeWtwbG9sNkpXblBjd0t3bklLMm1SaGtPVXpWSGFYOXFsNlJTWldRTEVBQW9QejRNRy9hMG9wCmJsUGNpQmg4N2F0b3c3d3VkZUxBQ25Na0M0alUzdkRSMmVtc3Y4K2NEd1o3OFVBQ1hMdjhyemJrY3ZpTWlwbkoKU3A4UjFBcFNGQ3hISWpXcjBQVy8vL2sxeENjTzBaOEIveVdvV0VlY2RyOHVld2MvQnV3Mm91RkVlRTBoa25kSQpQS2o4eUtENE90QVJqQVZhRUF4cGxyL1RvUGgrYnhmb1dLaGtnMVRNSkhFK1hZMkdtVVN1cEppMXJ5Y1lrcloxCmtmUWxLbzB3WUJ2TmpOT3dmeExXbHNEMVBVdDRzNmsvT1RqZUViYkZSeTc3T2xRczlJbHlsMm13bFNMa2JkMnIKTjJ6azV0QTdZb3hrMldCNU5iQll1RmtxWkRoSnR5NEV0MGV6dUNhTElOSEpuM3I4SWlhS1R2aUJxOHVmaGgvYQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo="
}

variable "td_secret_admission_cert" {
  type        = string
  default     = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURURENDQWpTZ0F3SUJBZ0lSQU01dDI3dHdpd0FYN2k4OWp3QWxxejh3RFFZSktvWklodmNOQVFFTEJRQXcKS0RFU01CQUdBMVVFQ2hNSlZIZHBjM1JzYjJOck1SSXdFQVlEVlFRREV3bFVkMmx6ZEd4dlkyc3dIaGNOTWpJdwpOREEwTWpFeE56QXdXaGNOTWpVd05EQXpNakV4TnpBd1dqQVVNUkl3RUFZRFZRUUtFd2xVZDJsemRHeHZZMnN3CmdnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUURvcTA2bE5pay9FcEJwRk4vdW1obk8KU2NKcVZuT0tjTWFiR0xnbkNkeW1TOWEzZ3dnQVlZS05PYnBkVm5YVnY4YmpLdHBOWkVsVmh1dzREOUFhSG1kdgpiSGwrUDdWTFpUZ3EyMDh3OE05ME4xb29sWk9LOS9Db0hxc2hveGV6QXNzMjJtS3Q2RElyaWlyQ00yd3ZybVJCCjlZMENEcnJYUUFBUnJ5WEFpS1p6cHhlWmZsUVNndXJxVTJ1b0d4aVMxemxXZXhCSGJBSnBzWCtYL1ZQc3lZU0oKcGtxU29BV21nd3dEUzNJTVZUODRCVFU2QjdGOHJtR25QamRZVzY4dkFuU3pGb0FZTnNKZjdhQytnMHRsNEF3RQpYcW0wN0w3SlRMcnBzamRUZGcxbnB5YTg2dkc1eEdwS2JhYzRpNFhOSzZkT3JMVnBKUnJFK1FiRzZ6QjMxaVNWCkFnTUJBQUdqZ1lRd2dZRXdEZ1lEVlIwUEFRSC9CQVFEQWdPb01CMEdBMVVkSlFRV01CUUdDQ3NHQVFVRkJ3TUMKQmdnckJnRUZCUWNEQVRBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRk4wTHJsd00rQ1hyRVo5ZQpaUEZ5M1hqQ3RieVlNQ0VHQTFVZEVRUWFNQmlDRm1SbFptVnVaR1Z5TG5SM2FYTjBiRzlqYXk1emRtTXdEUVlKCktvWklodmNOQVFFTEJRQURnZ0VCQURNMUhTQy9OU0pmYjFFY3g5WmxJY3hwYi9Cb25DdS9wZ1ZMMnloVnFWVGMKT1ZVWTBybm9Ra3NQUStCNmNFRlBhTlllZlZFN2tQbnZpVFRpR1hRR1dNZGtlT3JpWndxeDFXSk45UXp5N1JCMQp0cDVSUmJKRTIwMTZQdFJuVmI1elN5NmplSDlxQVRXSUdoQ0JORXlTdGJVY2RhNUZzOXNGZTRjbFdzdHJ5OU95CjJ3T0tIdlJlWnlsUXFMa3M3KzdGdEVaVEJCM2k1UmxnSVY4S3N5dDQxTWw1NWw0YWhZdlhTN29VU0VaM0xZZzkKTFlTQXpGbzhtUG9kZklXSmJHdVV5TVlUeWlPWmtLMG90aEdWUHhhM3VyZ0VZVlh0endQNDQzQ1c1Y2o3NmpOUgp4Y3ZJbUZtK1htdDZ3Vy9oWWR1NnBOcXRlaFIyMWhHdnViNFpiQ3IrMDFRPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
}

variable "td_secret_admission_key" {
  type        = string
  default     = "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpQcm9jLVR5cGU6IDQsRU5DUllQVEVECkRFSy1JbmZvOiBBRVMtMjU2LUNCQyw4ZDViNDlkNjRkMmMyN2VkNTZjM2U3YWIyYmEzOTAzZAoKS1d3YzJXdEpsMXdOMk9Yd2dzTUk1SnU2SEpvamUzVjJnZzdpSTZMME1wb0FtQTQ2RmhlazZRbFJveUNXeHNOdAp2NE5PTWlLVnU5MEp5WFVoak83UWlPeWJaM0gxUFloRTY4WWdUN0JDMmdWYzRaVktKbzJmMVhTVnpWbnZGK2p5CjBGaWZYSUkxVzNYY3crQitwdW1iRXJ5NWYrdEFlMFNpL00xN09BTnNmUGRwcG53Y1M5dlpIdVBDRGp0eXBpR2wKZzJTZllQajFIWXN1aVBzTzZtc1BxcUM3OUViSnZlUUZyN3NQS0JrMk9QOWNFbFFsc2s5ajdLTmpFUk1VSHdkdApObEErM2JyV0c1NUJmSU9DQUdXejlsdmVGeVErTnRJR2JTaFQ5TmkyN3JlOFBqQWQ5TzZEV1ZRcnY4U0xvUm85CjJXa3MyaGI3elFaU2krN3haTFlPaGM2VkJiaGlIQURvbEhROVhrMEN2SjNXdk1IREtTVFVCSzBsQzVZY0g1M2gKOVVCZ2pQQ0l3bzAwS0huaU9IRXFxTVgyLzVoZWpxa285NXFITEkxOEROaGpQU0lhME91QU8wdS9wd2YvcWptNAp5ZDJvd1JXbGtKL1N5a25pMEdsWEVNWDV2YmM4QUNCRmMweHpuZFBjSnIrYUZJN2tRajEweFlFMVhITzBKd1JTCjBnU3BDR2RRY0FsQkVxUHY5V1FjQlRQZlh6bnVGRXhWMVJja3lTUGxRc0hVVEk5Ym5Lak5rSXdkalBxYjNJWlYKa01wZkVJM2ZLV0IrUHhxK2FGalVwcWtKVW9iUzVyWVRvcHdZRkVBaFM0K2d6Y01TTmNPUFp3aERDY3dzTXdvYwpyamZaQUltNUEwTEpXT0NBY3U3cWsxQlFFUEozWHhQNGlLbDJDOVlpa21HbU9odWwvZVowSGhlMXpyNDcrb2RVCmJENVFYbG1JMWpWU3UrQUNqR3hXQTREOXkxRG9hTFoxQTJWb1NhKzFvYlRjeDR5Y09zUlZrb3dpMm1BTjZXOXAKeG12dks5MTNtcG1SNkFudTJvZkxzVDN3VzhUd1BzME5jajRocUMyMnlSRnpNQlp3QVZKeVo4K09yVXA2L3ArZApCcUFaTGVaOFJobFE4MVZqK0FYOXZLOTkyQWg2V01QRFVJeFpmd3dMRmlMb0FIZWF2U0pJbDQ3NGFPc3ZpOGJICkNGYmI3QU1qRmFuZERCZUFlbndGaE5HSi9ZU05vVTVsdVArRHN5SmFBa1Y5WCtXNVUyYXZBRmVJcCtualloUTEKTVhFVnFUQ1NOa3pCOHVob3YvVnRENlBTUDhCL0RMN1hFK2I3NzBxd2prQWkyS3VJemZ4enFkWi9hRzlYVi84Ywp1RnJMNmlGRmE3aE82WURKUXBWSHRPaGdCaHUrdjlrNmhtVkFURW5pQnJRY3lYc1k5dzZnV2VwZ1JiSHRuWHRuCkovV0JNczdQdllaY0xFNWo2YWdwRm1LMDVXeFg4NXBHelhMb3MvSTNoSWwyUklCZkRaRnRpZ01NUnZ1Rm1yNzEKSDBMZXlldjQwUmF0NjdmZkxYRjJJbVhBOFlaK25lL0FBM3BSdFZ1SWRYVkI4UjVpdm02UEljVzkwM1hPVkFsKwpnbTF4Rk8yczRZdGM0ZTRZdFQ0YzEvUXAyU1RlUk5xa2RnUFJtOWoyOGxnT2V5bS9LZmpZR0hqWVI4dy9wSU9FClQ4R2Flc0thMU5NVjA5cGpBNFY3RGcwdWVEZ25yaGFqd3c4djlCeEVodEZlUFVBOS9PMUZPT1ViZkNsTk0yclAKNVNkTFJjWkMvSzB0TlZYdDRBS0U2bkM2N0JMZW9iOVpYZkdzOCtBOWYySzd6MGpybC9HdFZqaXIyQ01ZWEM4aAo1VG40aXk0LytZNzFLL2JOWGIyeldHOXQ2d0tDMWNuRVdyeGRvN2x0YldGalc2TS9sRjR5QnR3MzZNYjYyRWhkClRGN2VOc3RkZ24rSTVwemRiQmVRaTdMY20wN21kTFlremc4SERVU2YzM1pPV2RaVlZVSTYyajM4ZEh1dlQ1aVgKdFMrU01iMFhpL3gyeE5jenNmQjgzYzFHYnNSM21hNVB5R0RYR1cxTFBPQ20wbHVzNGNDOERBMTZlVnFWZmJnTgotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo="
}

variable "td_secret_validating_webhook_ca" {
  type        = string
  default     = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURIVENDQWdXZ0F3SUJBZ0lSQU9FdkU0WWRIN3dkeU1SWUZJSlFuMll3RFFZSktvWklodmNOQVFFTEJRQXcKS0RFU01CQUdBMVVFQ2hNSlZIZHBjM1JzYjJOck1SSXdFQVlEVlFRREV3bFVkMmx6ZEd4dlkyc3dIaGNOTWpJdwpNakkzTURneE9EQXdXaGNOTWpVd01qSTJNRGd4T0RBd1dqQW9NUkl3RUFZRFZRUUtFd2xVZDJsemRHeHZZMnN4CkVqQVFCZ05WQkFNVENWUjNhWE4wYkc5amF6Q0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0MKZ2dFQkFOb1lNY3BJZWNCMjF6S29qTWdRRDV2RjIvNEd0K1FaeVVJRWZaTEFHU0lBVEwydXJLNC8wbUUrU0lVWApRSWtxVUNmVEw1TXQzNmc1VU9rRUp1eWJFYng5NkRlODJhQnhyNGJiVXh4aCtlWS9WQm0weTNaSHpmMWE5M0NtCm1xcVZ0VytTQXl5S1FGWWpsRlZKMHRha2U3TlNDUVQvL3hVVmQzZ3ROY1ZPMWhISzFHU2w1c04vbGtYcHdmS3QKRit4UDE0dmord1pGR1JGRnJpOXFmYWNLTkdsVnNRTGdFbExBZjJmdGRjRlFMRWFlcDh6UlR5U2NrRmhGN1gxRAo5SXNUOHpBYnVMdzA2M3F0Z0hrWi9malAvU0xreGxWSkE4ajJiSTRrbVpER08yQ1dlSjJyOVpwcDNFTmNnb3FECmllVzlqdFRuTEs5Qk9IbkthQjV6cUloUHNOOENBd0VBQWFOQ01FQXdEZ1lEVlIwUEFRSC9CQVFEQWdLc01BOEcKQTFVZEV3RUIvd1FGTUFNQkFmOHdIUVlEVlIwT0JCWUVGTjBMcmx3TStDWHJFWjllWlBGeTNYakN0YnlZTUEwRwpDU3FHU0liM0RRRUJDd1VBQTRJQkFRQktxVXlkRjNoNVlaOGQxZjRCN1JiNDFLVnVVeDJJUjNaci9naHhpa1ZwCjZUVm81bTBOZHA2NE40Y0pPN2Vkc0J5M0RHU0RVeGo1ZjNZaUs0ZUVQNnlLanNqd2FvdlIyTmVQdW5oMlFiSmcKOEdxUTNEaksvWlo5TCt3Ykw5TWZhODhBQzBja0MzMDVhM3hIb1RCSGlPOU5ZZk1UcXJMZFVod0NPOTgrSHoxUApjL3VFUk5VQ2o5YnR4NEk5aVlleTI0TGxMeWZxVzlzQUtEZkQrbFJZL2o3bnYyYW1COHl1RlRFbThwUUMyQ1FyCmlYTGJrWWxQb0IraElpR0Z1cXoxTWxFK3Z3STFxblVpb1g4R0ZXd1JEdkJTTmpGSjkrQ2E1TCtsZXl1OUd0U2sKUHlQU0w2L054S0xSUDd5d2ZzeGxwWWY5VE96WFE2Z3hxMG1BYVlFU3A2ZnkKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo="
}

variable "twistlock_namespace_labels" {
  description = "A mapping of labels to assign to twistlock namespace"
  type        = map(string)
  default     = {}
}

#Cluster Autoscaler Variables

variable "assume_role_policy_autoscaler" {
  type        = string
  description = "The policy that grants an entity permission to assume the role. User need to provide the assume role policy in json file format."
  default     = null
}
variable "managed_policy_arns_autoscaler" {
  type        = list(string)
  description = "Set of exclusive IAM managed policy ARNs to attach to the IAM role. If this attribute is not configured, Terraform will ignore policy attachments to this resource. When configured, Terraform will align the role's managed policy attachments with this set by attaching or detaching managed policies. Configuring an empty set (i.e., managed_policy_arns = []) will cause Terraform to remove all managed policy attachments."
  default     = []
}

variable "cluster_autoscaler_name" {
  description = "Release name."
  type        = string
  default     = "cluster-autoscaler"
}

variable "cluster_autoscaler_chart" {
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if repository is specified. It is also possible to use the <repository>/<chart> format here if you are running Terraform on a system that the repository has been added to with helm repo add but this is not recommended."
  type        = string
  default     = "cluster-autoscaler"
}

variable "cluster_autoscaler_repository" {
  description = "Repository URL where to locate the requested chart."
  type        = string
  default     = "https://kubernetes.github.io/autoscaler"
}

variable "cluster_autoscaler_namespace" {
  description = "Namespace to install the chart."
  type        = string
  default     = "kube-system"
}

variable "cluster_autoscaler_helm_version" {
  description = "Helm chart version."
  type        = string
  default     = "9.21.0"
}

variable "cluster_autoscaler_timeout" {
  description = "Repository URL where to locate the requested chart."
  type        = number
  default     = 300
}

variable "cluster_autoscaler_image_tag" {
  description = "Cluster Autoscaler Image Tag"
  type        = string
  default     = "v1.23.0"
}

# Karpenter Variables
variable "enable_karpenter" {
  type        = bool
  default     = false
}

variable "karpenter_name" {
  description = "Release name."
  type        = string
  default     = "karpenter"
}

variable "karpenter_chart" {
  description = "Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if repository is specified. It is also possible to use the <repository>/<chart> format here if you are running Terraform on a system that the repository has been added to with helm repo add but this is not recommended."
  type        = string
  default     = "karpenter"
}

variable "karpenter_repository" {
  description = "Repository URL where to locate the requested chart."
  type        = string
  default     = "oci://public.ecr.aws/karpenter"
}

variable "karpenter_namespace" {
  description = "Namespace to install the chart."
  type        = string
  default     = "karpenter"
}

variable "karpenter_helm_version" {
  description = "Helm chart version."
  type        = string
  default     = "v0.23.0"
}

variable "karpenter_timeout" {
  description = "Repository URL where to locate the requested chart."
  type        = number
  default     = 300
}

variable "karpenter_instance_profile" {
  description = "Karpenter Instance Profile Name."
  type        = string
  default     = null
}

variable "cluster_log_skip_destroy" {
  description = "Skip destroying EKS Cluster Cloud Watch Logs while deleting the cluster"
  type        = bool
  default     = false
}

variable "fargate_log_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
  default     = 90
}

variable "fargate_log_skip_destroy" {
  description = "Skip destroying EKS Fargate Cloud Watch Logs while deleting the cluster"
  type        = bool
  default     = false
}