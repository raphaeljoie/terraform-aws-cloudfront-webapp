output "domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "static_bucket" {
  value = local.bucket_name
}

output "bucket_policy_json" {
  value = data.aws_iam_policy_document.bucket_policy.json
}
