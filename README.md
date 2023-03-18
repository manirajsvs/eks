

## Anthem EKS Cluster Module

This module will create a EKS Cluster without nodes and ALB controller.

## HIPPA eligibility status

1. AWS EKS is eligible.

## Security Guardrail reference

https://confluence.anthem.com/pages/viewpageattachments.action?pageId=299009562&sortBy=date&startIndex=0&preview=/299009562/407571792/Anthem%20AWS%20Security%20Patterns%20-%20AWS-EKS-BUNDLE.docx

## Pre-Requisite

1. This module is to to create a EKS cluster without nodes and ALB controller. 
2. Use terraform-aws-eks-managed-node-group module for managed node group creation.
3. Requires KMS key for cloudwatch service to enable the cloudwatch logging. Module creates the required cloudwatch KMS key.
4. KMS is enforced and validated inside the code, module creates the required KMS key.
5. Cluster enable log type should be blank if you don't have KMS key for cloudwatch service.
6. Cluster endpoint public access is disabled. only private access is enabled by default.
7. Required security group will be created by default with this module.
8. Egress all port and protocol with the cidr 0.0.0.0/0 is allowed by default.
9. Ingress port 443 and protocol HTTPS with cidr 30.0.0.0/8, 33.0.0.0/8, 10.0.0.0/8 is allowed by default.
10. This module internally creates the OIDC provider.
11. This module adds the required tagging to the subnets.
12. Requires IAM roles and policies: Cluster IAM role is created with default name (users can specify a specific name if needed with iam_role_name parameter) inside the module by assuming the service eks.amazonaws.com and AmazonEKSClusterPolicy policy is attached to the cluster IAM role.
13. Subnets should be private only. 
14. Kubernetes config map named aws-auth is created within the module with specified master user role. To add additional roles, add using additional_roles parameter at the time of initial creation as config map cannot be updated with subsequent applies.
15. If user want attach any managed_policy_arns then can attach by using managed_policy_arns variable. but the value is defaulted like below so they need to attach value along with below value.
```managed_policy_arns =  ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]```
16. If user want to attach assume_role_service_names  then can attach by using assume_role_service_names variable.but the value is defaulted like below so they need to attach value along with below value.
```assume_role_service_names = ["eks.amazonaws.com"]```
17. To create customized Assume role policy user must have json file as assume role policy like below:
Assume Role Policy
```bash
{
    "Version": "2012-10-17",
    "Statement": {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": { "Service": "eks.amazonaws.com" }
    }
}
```
For client build script user need to provide the input as:
```bash
assume_role_policy    = file("assume_role_policy.json)
```
18. If user wants to provide subnet_ids variable then can pass otherwise it will take by default
19. If user wants to provide vpc_id variable then can pass otherwise it will take by default 
20. If user wants to provide iam role separetely then they can pass value to variable "role_arn" otherwise it will take by default
21. Autoscaler is created within the module. Cluster Autoscaler(CAS) is configured by default. If you want you use Karpenter as an default Autoscaler pass `enable_karpenter` variable while calling the module and set the value as `true`
22. Karpenter/Cluster Autoscaler will be deployed as Helm Charts. Both Karpenter and Cluster Autoscaler can't be deployed at a time. `enable_karpenter = true` deploys Karpenter, `enable_karpenter = false` deploys Cluster Autoscaler.
23. If you are using Karpenter as an Autoscaler [Refer Here](https://confluence.elevancehealth.com/display/ENTCLOUD/Cluster+Autoscaling+using+Karpenter) for configuring Provisioners and AWSNodeTemplate.
24. Fargate profile named `autoscaler` will be created within the module to run Karpenter/Cluster Autoscaler Pods.
25. `aws-observability` namespace and `aws-logging` configmap will be created to forward fargate logs to Cloudwatch. Log group name will be `<clustername>-fargate-profile-logs`
26. Karpenter/Cluster Autoscaler logs will be forwarded to Cloud Watch by default.
27. Users can create additional fargate profiles using terraform-aws-eks-fargate module if required.

## Mandatory Tags Note:
*	As per redesigned new mandatory tags, mandatory tags along with any additional tags have to be added through template configuration within the modules as below
*	Have a reference of mandatory tags module within the template configuration as shown in example script below.
```bash
# Mandatory Tag Workspace Variables
variable "apm-id" {}
variable "application-name" {}
variable "app-support-dl" {}
variable "app-servicenow-group" {}
variable "business-division" {}
variable "company" {}
variable "compliance" {}
variable "costcenter" {}
variable "environment" {}
variable "PatchGroup" {}
variable "PatchWindow" {}
variable "ATLAS_WORKSPACE_NAME" {}

# Mandatory Tags Module 
module "mandatory_tags" {
  source               = "cps-terraform.anthem.com/<ORG_NAME>/terraform-aws-mandatory-tags-v2/aws"
  tags                 = {}
  apm-id               = var.apm-id
  application-name     = var.application-name
  app-support-dl       = var.app-support-dl
  app-servicenow-group = var.app-servicenow-group
  business-division    = var.business-division
  compliance           = var.compliance
  company              = var.company
  costcenter           = var.costcenter
  environment          = var.environment
  PatchGroup           = var.PatchGroup
  PatchWindow          = var.PatchWindow
  workspace            = var.ATLAS_WORKSPACE_NAME
}
```
*	Mandatory tags module should be referred in tags attribute as below:
tags = module.mandatory_tags.tags
*	Any additional tags can be merged to tags attribute as below:
tags = merge(module.mandatory_tags.tags, {"sample" = "abc"})



## Usage

To run this example you need to execute:

```bash
#Example script
module "eks_cluster" {
  source                          = "cps-terraform.anthem.com/<ORGANIZATION NAME>/terraform-aws-eks-cluster/aws"
  version                         = "1.0.1"
  #Mandatory Tags
  tags                            = module.mandatory_tags.tags
  #Required Parameters
  cluster_name                    = "test-eks-cluster"
  master_user                     = <IAM Role who will be admin of EKS cluster>
  #Optional Parameters
  vpc_id                          = "vpc-<ID>"
  cluster_version                 = "1.19"
  cluster_enabled_log_types       = ["api", "audit"]
  cluster_log_retention_in_days   = 90
  cluster_create_timeout          = "30m"
  cluster_delete_timeout          = "15m"
  additional_roles                = [   
    {
      rolearn  = "arn:aws:iam::<ACCOUNT NUMBER>:role/<ROLE NAME>"
      username = "<ROLE NAME>:{{SessionName}}"
      groups = [
        "system:masters"
      ]
    }
  ]
}

#Example kubernetes.tf script, to include within the test build script.
data "aws_eks_cluster" "cluster" {
  name = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_id
}

provider "kubernetes" {  
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
provider "helm" { 
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token 
  }
}

#Initialize Terraform
terraform init

#Terraform Dry-Run
terraform plan

#Create the resources
terraform apply

#Destroy the resources saved in the tfstate
terraform destroy
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_roles | Additional IAM roles to add to `aws-auth` ConfigMap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| assume\_role\_policy | The policy that grants an entity permission to assume the role. User need to provide the assume role policy in json file format. | `string` | `null` | no |
| assume\_role\_policy\_autoscaler | The policy that grants an entity permission to assume the role. User need to provide the assume role policy in json file format. | `string` | `null` | no |
| assume\_role\_service\_names | Required list of services to create the assume role trust relationship. | `list(string)` | <pre>[<br>  "eks.amazonaws.com"<br>]</pre> | no |
| cluster_autoscaler_chart | Chart name to be installed | `string` | `cluster-autoscaler` | no |
| cluster_autoscaler_helm_version | Specify the exact chart version to install. If this is not specified, the latest version is installed | `string` | `9.21.0` | no |
| cluster_autoscaler_image_tag | Cluster Autoscaler Image Tag | `string` | `v1.23.0` | no |
| cluster_autoscaler_name | Release name | `string` | `cluster-autoscaler` | no |
| cluster_autoscaler_namespace | The namespace to install the release into | `string` | `kube-system` | no |
| cluster_autoscaler_repository | Repository URL where to locate the requested chart | `string` | `https://kubernetes.github.io/autoscaler` | no |
| cluster_autoscaler_timeout | Time in seconds to wait for any individual kubernetes operation | `number` | `300` | no |
| cluster\_create\_timeout | Default is 30m. Timeout value when creating the EKS cluster. | `string` | `"30m"` | no |
| cluster\_delete\_timeout | Default is 15m. Timeout value when deleting the EKS cluster. | `string` | `"15m"` | no |
| cluster\_enabled\_log\_types | Default is []. A list of the desired control plane logging to enable. valid list is ["api", "audit", "authenticator", "controllerManager", "scheduler"]. | `list(any)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| cluster\_kms\_key\_id | Cluster EC2 KMS Key ID | `string` | `""` | no |
| cluster\_log\_kms\_key\_id | Cluster Cloudwatch KMS Key ID | `string` | `""` | no |
| cluster\_log\_retention\_in\_days | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| cluster\_log\_skip\_destroy | Skip destroying EKS Cluster Cloud Watch Logs while deleting the cluster | `bool` | `false` | no |
| cluster\_name | Name of the EKS cluster. | `string` | n/a | yes |
| cluster\_version | Default is "". Desired Kubernetes master version. If you do not specify a value, the latest available version at resource creation is used and no upgrades will occur except those automatically triggered by EKS. The value must be configured and increased to upgrade the version when desired. Downgrades are not supported by EKS. | `string` | `""` | no |
| config\_map\_name | Default is aws-auth. Name of the config map, must be unique. Cannot be updated. | `string` | `"aws-auth"` | no |
| enable\_karpenter | Use karpenter as an Cluster Autoscaler | `bool` | `false` | no |
| fargate\_log\_retention\_in\_days | Number of days to retain log events. Default retention - 90 days |  `number` | `90` | no |
| fargate\_log\_skip\_destroy | Skip destroying EKS Fargate Cloud Watch Logs while deleting the cluster | `bool` | `false` | no |
| karpenter\_chart | Chart name to be installed | `string` | `karpenter` | no |
| karpenter\_helm\_version | Specify the exact chart version to install. If this is not specified, the latest version is installed | `string` | `v0.23.0` | no |
| karpenter\_instance\_profile | Karpenter Instance Profile Name | `string` | `null` | no |
| karpenter\_name | Release name | `string` | `karpenter` | no |
| karpenter\_namespace | The namespace to install the release into | `string` | `karpenter` | no |
| karpenter\_repository | Repository URL where to locate the requested chart | `string` | `oci://public.ecr.aws/karpenter` | no |
| karpenter\_timeout | Time in seconds to wait for any individual kubernetes operation | `number` | `300` | no |
| managed\_policy\_arns | Set of exclusive IAM managed policy ARNs to attach to the IAM role. If this attribute is not configured, Terraform will ignore policy attachments to this resource. When configured, Terraform will align the role's managed policy attachments with this set by attaching or detaching managed policies. Configuring an empty set (i.e., managed\_policy\_arns = []) will cause Terraform to remove all managed policy attachments. | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"<br>]</pre> | no |
| managed\_policy\_arns\_autoscaler | Set of exclusive IAM managed policy ARNs to attach to the IAM role. If this attribute is not configured, Terraform will ignore policy attachments to this resource. When configured, Terraform will align the role's managed policy attachments with this set by attaching or detaching managed policies. Configuring an empty set (i.e., managed\_policy\_arns = []) will cause Terraform to remove all managed policy attachments. | `list(string)` | `[]` | no |
| master\_user | IAM Role name of the user who will be the administrator of the EKS Cluster | `string` | n/a | yes |
| namespace | Default is kube-system. Namespace defines the space within which name of the config map must be unique. | `string` | `"kube-system"` | no |
| role\_arn | ARN of the IAM role that provides permissions for the Kubernetes control plane to make calls to AWS API operations on your behalf. Ensure the resource configuration includes explicit dependencies on the IAM Role permissions by adding depends\_on if using the aws\_iam\_role\_policy resource or aws\_iam\_role\_policy\_attachment resource, otherwise EKS cannot delete EKS managed EC2 infrastructure such as Security Groups on EKS Cluster deletion. | `string` | `null` | no |
| subnet\_ids | Identifiers of EC2 Subnets to associate with the EKS Node Group. These subnets must have the following resource tag: kubernetes.io/cluster/CLUSTER\_NAME (where CLUSTER\_NAME is replaced with the name of the EKS Cluster). | `list(string)` | `null` | no |
| tags | A mapping of tags to assign to all resources | `map(string)` | n/a | yes |
| twistlock\_namespace\_labels | A mapping of labels to assign to twistlock namespace | `map(string)` | `{}` | no |
| vpc\_id | VPC ID to attached the security group | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_arn | The Amazon Resource Name (ARN) of the cluster. |
| cluster\_id | The name of the cluster. |
| cluster\_role\_arn | The Amazon Resource Name (ARN) specifying the cluster role. |
| cluster\_role\_name | The name of the cluster role. |
| cluster\_security\_group\_id | The cluster security group that was created by Amazon EKS for the cluster. |
| custom\_security\_group\_id | Security group created for EKS cluster creation |
| endpoint | The endpoint for your Kubernetes API server. |
| identity | Issuer URL for the OpenID Connect identity provider. |
| kubeconfig-certificate-authority-data | The base64 encoded certificate data required to communicate with your cluster. |
| openID\_URL | The URL of the identity provider. |
| platform\_version | The platform version for the cluster. |
| private-subnet\_id | n/a |
| status | The status of the EKS cluster. One of CREATING, ACTIVE, DELETING, FAILED. |
| version | The Kubernetes server version for the cluster. |
| vpc\_id | The VPC associated with your cluster. |

## Testing

1. Created cluster using example script.
2. Could see the cluster is created and the endpoint is accessible.
3. Could see the configmap being created with specified master user as well as additional roles.