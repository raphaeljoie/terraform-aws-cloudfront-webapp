# Deploy an optimized web app

* [x] static assets distributed via S3
* [x] Dynamic routes (API and GUI) via Lambda functions
* [x] Everything distributed on Cloud front

## Usage
1. Bundle your application as a lambda function
2. Gather the static assets in a S3 bucket
3. Use this module to connect everything

```tf
module "webapp" {
  source = "git::https://github.com/raphaeljoie/terraform-aws-cloudfront-webapp.git?ref=v0.1.3"

  # Dynamic endpoints
  lambda_qualified_arn = aws_lambda_function.lambda.lambda_qualified_arn
  
  # Static endpoints
  s3_bucket_name = "mywebappstaticassets"
  create_bucket = true  # policy available in output for existing buckets
  
  # Domain name
  domain_name = "my.domain.name"
  # create_certificate = true # Not yet implemented
  certificate_arn = aws_acm_certificate.certificate.arn

  paths = [
    {
      type = "static"
      path = "public/*"
    }, {
      type = "dynamic"
      path = "api/*"
    }
  ]

  default_path = {
    type = "dynamic"
  }
}
```

```shell
$ terraform apply
$ DOMAIN_NAME=$(terraform output domain_name)
$ curl https://${DOMAIN_NAME}/api/any_endpoint
$ curl https://${DOMAIN_NAME}/public/any_asset.mp3
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.40.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.certificate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_cloudfront_distribution.s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_route53_record.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_policy.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN to the ACM SSL certificate for the custom domain name. Required when `custom_domain_name` is set | `string` | `null` | no |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Set to false to use an existing S3 bucket. Additional statement available in output | `bool` | `true` | no |
| <a name="input_custom_domain_name"></a> [custom\_domain\_name](#input\_custom\_domain\_name) | Custom domain name for the distribution. Use `output.domain_name` for the creation of appropriate `CNAME` records | `string` | `null` | no |
| <a name="input_default_path"></a> [default\_path](#input\_default\_path) | n/a | `object({type: string})` | n/a | yes |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | Object that you want CloudFront to return (for example, index.html) when an end user requests the root URL | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the CloudFront distribition | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_is_ipv6_enabled"></a> [is\_ipv6\_enabled](#input\_is\_ipv6\_enabled) | n/a | `bool` | `true` | no |
| <a name="input_lambda_qualified_arn"></a> [lambda\_qualified\_arn](#input\_lambda\_qualified\_arn) | Qualified ARN (including version number) of the lambda function for non static routes | `string` | n/a | yes |
| <a name="input_paths"></a> [paths](#input\_paths) | n/a | `list(object({path: string, type: string}))` | `[]` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the bucket to create or to use for static assets | `string` | n/a | yes |
| <a name="input_s3_bucket_path"></a> [s3\_bucket\_path](#input\_s3\_bucket\_path) | If you want CloudFront to always request content from a particular directory in the origin, enter the directory path, beginning with a forward slash (/). Do not add a slash (/) at the end of the path. CloudFront appends the directory path to the origin domain name | `string` | `null` | no |
| <a name="input_s3_bucket_regional_domain_name"></a> [s3\_bucket\_regional\_domain\_name](#input\_s3\_bucket\_regional\_domain\_name) | Required when `create_s3_bucket` is set to false | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_policy_json"></a> [bucket\_policy\_json](#output\_bucket\_policy\_json) | n/a |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | n/a |
| <a name="output_static_bucket"></a> [static\_bucket](#output\_static\_bucket) | n/a |
<!-- END_TF_DOCS -->

## Doc
* [Restrictions on edge functions](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/edge-functions-restrictions.html)

## TODO
- [ ] allow no lambda
- [ ] Add support for certificate creation + route53 domain validation
- [ ] documentation of lambda restrictions (including permissions for logging)
