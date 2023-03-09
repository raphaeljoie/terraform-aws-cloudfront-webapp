locals {
  s3_origin_id = "s3StaticAssets"
}

resource "aws_cloudfront_origin_access_control" "default" {
  name = var.create_s3_bucket ? aws_s3_bucket.this[0].bucket_regional_domain_name : var.s3_bucket_regional_domain_name
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = var.create_s3_bucket ? aws_s3_bucket.this[0].bucket_regional_domain_name : var.s3_bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id = local.s3_origin_id
    origin_path = var.s3_bucket_path
  }

  enabled = var.enabled
  is_ipv6_enabled = var.is_ipv6_enabled
  comment = var.description
  default_root_object = "index.html"

  #logging_config {
  #  include_cookies = false
  #  bucket          = "mylogs.s3.amazonaws.com"
  #  prefix          = "myprefix"
  #}

  aliases = var.custom_domain_name == null ? [] : [var.custom_domain_name]

  dynamic "ordered_cache_behavior" {
    for_each = var.paths
    content {
      path_pattern = ordered_cache_behavior.value.path
      allowed_methods = ordered_cache_behavior.value.type == "static" ? ["GET", "HEAD" ] : [
        "DELETE",
        "GET",
        "HEAD",
        "OPTIONS",
        "PATCH",
        "POST",
        "PUT"]
      cached_methods = ["GET", "HEAD"]
      target_origin_id = local.s3_origin_id

      forwarded_values {
        query_string = ordered_cache_behavior.value.type == "static" ? false : true
        headers = []

        cookies {
          forward =  ordered_cache_behavior.value.type == "static" ? "none" : "all"
        }
      }

      # Restrictions on Lambda@Edge
      # The following Lambda features are not supported by Lambda@Edge:
      # * ...
      # * Lambda environment variables.
      # * ...
      # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/edge-functions-restrictions.html
      #environment {
      #  variables = {
      #    foo = "bar"
      #  }
      #}
      # Restrictions on Lambda@Edge
      # The following Lambda features are not supported by Lambda@Edge:
      # * ...
      # * Lambda functions that use the arm64 architecture.
      # * ...
      # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/edge-functions-restrictions.html
      # Restrictions on Lambda@Edge
      # The Lambda function must be in the US East (N. Virginia) Region.
      # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/edge-functions-restrictions.html
      #provider = aws.us-east-1
      dynamic "lambda_function_association" {
        for_each = ordered_cache_behavior.value.type == "static" ? [] : [var.lambda_qualified_arn]
        content {
          event_type   = "origin-request"
          include_body = true
          lambda_arn = var.lambda_qualified_arn
        }
      }

      min_ttl = 0
      default_ttl = 86400
      max_ttl = 31536000
      compress = true
      viewer_protocol_policy = "https-only"
    }
  }

  default_cache_behavior {
    allowed_methods = var.default_path.type == "static" ? ["GET", "HEAD"] : [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    dynamic "lambda_function_association"{
      for_each = var.default_path.type == "static" ? [] : [var.lambda_qualified_arn]
      content {
        event_type   = "origin-request"
        include_body = true
        lambda_arn =  var.lambda_qualified_arn
      }
    }

    compress = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 0
    max_ttl = 31536000
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      #restriction_type = "whitelist"
      #locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = var.tags

  viewer_certificate {
    acm_certificate_arn             = var.custom_domain_name == null ? null : local.acm_certificate_arn
    cloudfront_default_certificate  = var.custom_domain_name == null ? true : false
    ssl_support_method              = var.custom_domain_name == null ? null : "sni-only"
  }
}

locals {
  acm_certificate_arn = var.acm_certificate_arn
}
