data "aws_vpc" "vpc" {
  id = var.vpc_id
  filter {
    name   = "tag:Name"
    values = ["aws-landing-zone-VPC", "lz-additional-vpc-VPC"]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id == null ? "${data.aws_vpc.vpc.id}" : var.vpc_id]
  }

  tags = {
    Network = "Private"
  }
}

output "private-subnet_id" {
  value = data.aws_subnets.private.ids
}

resource "aws_ec2_tag" "private_subnet_tag1" {
  count       = length(data.aws_subnets.private.ids)
  resource_id = sort(data.aws_subnets.private.ids)[count.index]
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

resource "aws_ec2_tag" "private_subnet_tag" {
  count       = length(data.aws_subnets.private.ids)
  resource_id = sort(data.aws_subnets.private.ids)[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}