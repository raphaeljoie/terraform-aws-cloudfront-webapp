output "domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "static_bucket" {
  value = local.bucket_name
}
