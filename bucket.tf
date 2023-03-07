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

# TODO output policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  count = var.create_s3_bucket ? 1 : 0
  bucket = local.bucket_name
  policy = jsonencode(
  {
    Id = "PolicyForCloudFrontPrivateContent"
    Statement = [
      {
        Action = "s3:GetObject"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
          }
        }
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Resource = "arn:aws:s3:::${local.bucket_name}/*"
        Sid = "AllowCloudFrontServicePrincipal"
      },
    ]
    Version = "2008-10-17"
  }
  )
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  count = var.create_s3_bucket ? 1 : 0
  bucket = local.bucket_name
  acl = "private"
}
