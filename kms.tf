data "aws_region" "current" {
}

#Cloudwatch KMS Key
resource "aws_kms_key" "kms_key_cwl" {

  description                        = "EKS Cloudwatch KMS Key"
  key_usage                          = "ENCRYPT_DECRYPT"
  policy                             = data.aws_iam_policy_document.cwl_key_policy.json
  deletion_window_in_days            = 30
  is_enabled                         = true
  enable_key_rotation                = "true"
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  bypass_policy_lockout_safety_check = true
  tags                               = var.tags

  lifecycle {
    ignore_changes = [policy]
  }
}

resource "aws_kms_alias" "cwl_key_alias" {

  name          = "alias/eks-cwl-${var.cluster_name}-v2"
  target_key_id = aws_kms_key.kms_key_cwl.id

  lifecycle {
    ignore_changes = [name]
  }

}

data "aws_iam_policy_document" "cwl_key_policy" {

  # Enable Access for Key Administrators
  statement {
    sid    = "Enable Access for Key Administrators"
    effect = "Allow"
    principals {

      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/antm-ees-admin",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CCKM_Execution_Role"
      ]

    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  ### Enable Terraform Role Permissions
  statement {
    sid    = "Enable Terraform Role Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OlympusVaultServiceRole"]
    }

    actions = [
      "kms:CancelKeyDeletion",
      "kms:CreateAlias",
      "kms:CreateKey",
      "kms:DeleteAlias",
      "kms:DisableKey",
      "kms:EnableKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:List*",
      "kms:ScheduleKeyDeletion",
      "kms:UpdateAlias",
      "kms:GetKeyRotationStatus",
      "kms:GetKeyPolicy",
      "kms:EnableKeyRotation",
      "kms:DescribeKey",
      "kms:UpdateKeyDescription",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ReplicateKey",
      "kms:CreateGrant"
    ]
    resources = [
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*",
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:alias/*"
    ]

  }

  # Enable Developer Role Permissions
  statement {
    sid    = "Enable Developer Role Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.master_user}"]

    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "kms:TagResource",
      "kms:UntagResource"
    ]
    resources = [
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*",
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:alias/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["logs.${data.aws_region.current.name}.amazonaws.com"]

    }
  }

  # Restrict post-key-creation policy modification
  statement {
    sid    = "Restrict post-key-creation policy modification"
    effect = "Deny"
    not_principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/antm-ees-admin",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CCKM_Execution_Role"
      ]
    }
    actions = [
      "kms:PutKeyPolicy"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:BypassPolicyLockoutSafetyCheck"
      values   = ["true"]
    }
  }

  # Allow attachment of persistent resources
  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.master_user}"]

    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RetireGrant",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }

  #Cloudwatch permissions
  statement {
    sid    = "Cloudwatch Permissions"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]

    }
    actions = [
      "kms:Describe*",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]

    }
  }

}


#Cluster KMS Key
resource "aws_kms_key" "kms_key_cluster" {

  description                        = "EKS Cluster KMS Key"
  key_usage                          = "ENCRYPT_DECRYPT"
  policy                             = data.aws_iam_policy_document.cluster_key_policy.json
  deletion_window_in_days            = 30
  is_enabled                         = true
  enable_key_rotation                = "true"
  customer_master_key_spec           = "SYMMETRIC_DEFAULT"
  bypass_policy_lockout_safety_check = true
  tags                               = var.tags

  lifecycle {
    ignore_changes = [policy]
  }
}

resource "aws_kms_alias" "cluster_key_alias" {


  name          = "alias/eks-ec2-${var.cluster_name}-v2"
  target_key_id = aws_kms_key.kms_key_cluster.id

  lifecycle {
    ignore_changes = [name]
  }

}

data "aws_iam_policy_document" "cluster_key_policy" {


  # Enable Access for Key Administrators
  statement {
    sid    = "Enable Access for Key Administrators"
    effect = "Allow"
    principals {

      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/antm-ees-admin",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CCKM_Execution_Role"
      ]

    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  ### Enable Terraform Role Permissions
  statement {
    sid    = "Enable Terraform Role Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/OlympusVaultServiceRole"]
    }

    actions = [
      "kms:CancelKeyDeletion",
      "kms:CreateAlias",
      "kms:CreateKey",
      "kms:DeleteAlias",
      "kms:DisableKey",
      "kms:EnableKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:List*",
      "kms:ScheduleKeyDeletion",
      "kms:UpdateAlias",
      "kms:GetKeyRotationStatus",
      "kms:GetKeyPolicy",
      "kms:EnableKeyRotation",
      "kms:DescribeKey",
      "kms:UpdateKeyDescription",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ReplicateKey",
      "kms:CreateGrant"
    ]
    resources = [
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*",
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:alias/*"
    ]
  }

  # Enable Developer Role Permissions
  statement {
    sid    = "Enable Developer Role Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.master_user}"]

    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "kms:TagResource",
      "kms:UntagResource"
    ]
    resources = [
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*",
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:alias/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${data.aws_region.current.name}.amazonaws.com"]

    }
  }

  # Restrict post-key-creation policy modification
  statement {
    sid    = "Restrict post-key-creation policy modification"
    effect = "Deny"
    not_principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/antm-ees-admin",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/CCKM_Execution_Role"
      ]
    }
    actions = [
      "kms:PutKeyPolicy"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:BypassPolicyLockoutSafetyCheck"
      values   = ["true"]
    }
  }

  # Allow attachment of persistent resources
  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.master_user}"]

    }
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RetireGrant",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
  
  # Enable EKS Role Permissions 
  statement {
    sid    = "Enable EKS Role Permissions"
    effect = "Allow"
    actions = [
      "kms:UntagResource", "kms:TagResource", "kms:ReEncrypt*", "kms:GenerateDataKey*", "kms:Encrypt", "kms:DescribeKey", "kms:Decrypt" 
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-Role"]
    }
  } 
}
