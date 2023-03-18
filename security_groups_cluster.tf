locals {
  cluster_tags = {
    Name = "Security_group_${var.cluster_name}"
  }
}

resource "aws_security_group" "security-group-cluster" {
  name              = "${var.cluster_name}-security-group-cluster"
  description       = "Cluster communication with worker nodes"
  vpc_id            = var.vpc_id == null ? data.aws_vpc.vpc.id : var.vpc_id
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags              = merge(local.cluster_tags, var.tags)
}

resource "aws_security_group_rule" "cluster-ingress-workstation-https" {
  cidr_blocks       = ["30.0.0.0/8", "33.0.0.0/8", "10.0.0.0/8"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.security-group-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "allow-all-traffic" {
  depends_on        =[aws_eks_cluster.eks_cluster]
  cidr_blocks       = ["30.0.0.0/8", "33.0.0.0/8", "10.0.0.0/8", "100.94.0.0/16"]
  description       = "Allows all traffic from ElevanceHealth Legato Ashburn datacenters and additional CIDRs  to Cluster API Server"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  to_port           = 0
  type              = "ingress"
}
