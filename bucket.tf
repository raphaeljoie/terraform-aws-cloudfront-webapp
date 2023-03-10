resource "aws_s3_bucket" "this" {
  count = var.create_s3_bucket ? 1 : 0
  bucket = var.s3_bucket_name

  tags = var.tags
}

data "aws_s3_bucket" "this" {
  count = var.create_s3_bucket ? 0 : 1
  bucket = var.s3_bucket_name
}

locals {
  bucket_name = var.create_s3_bucket ? aws_s3_bucket.this[0].bucket : data.aws_s3_bucket.this[0].bucket
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = [
        "cloudfront.amazonaws.com"
      ]
    }

    resources = ["arn:aws:s3:::${local.bucket_name}/*"]

    actions = ["s3:GetObject"]
    condition {
      test = "StringEquals"
      values = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"]
      variable = "AWS:SourceArn"
    }
  }

  # Make sure Cloud Front returns 404 instead of 403
  # https://stackoverflow.com/questions/19037664/how-do-i-have-an-s3-bucket-return-404-instead-of-403-for-a-key-that-does-not-e
  statement {
    sid = "AllowListingFor404insteadOf403"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = [
        "cloudfront.amazonaws.com"
      ]
    }

    resources = ["arn:aws:s3:::${local.bucket_name}"]

    actions = [
      "s3:ListBucket"
    ]
    condition {
      test = "StringEquals"
      values = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"]
      variable = "AWS:SourceArn"
    }
  }
}

# TODO output policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  count = var.create_s3_bucket ? 1 : 0
  bucket = local.bucket_name
  policy = data.aws_iam_policy_document.bucket_policy.json
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count = var.create_s3_bucket ? 1 : 0
  bucket = local.bucket_name
  acl = "private"
}
