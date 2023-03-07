variable "lambda_qualified_arn" {
  type        = string
  description = "Qualified ARN (including version number) of the lambda function for non static routes"
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the bucket to create or to use for static assets"
}

variable "s3_bucket_path" {
  type        = string
  default     = null
  description = "If you want CloudFront to always request content from a particular directory in the origin, enter the directory path, beginning with a forward slash (/). Do not add a slash (/) at the end of the path. CloudFront appends the directory path to the origin domain name"
}

variable "s3_bucket_regional_domain_name" {
  type        = string
  default     = null
  description = "Required when `create_s3_bucket` is set to false"
}

variable "create_s3_bucket" {
  type        = bool
  default     = true
  description = "Set to false to use an existing S3 bucket. Additional statement available in output"
}

variable "paths" {
  type = list(object({path: string, type: string}))
  default = []
}

variable "default_path" {
  type = object({type: string})
}

variable "description" {
  type = string
  default = null
  description = "Description of the CloudFront distribition"
}

variable "enabled" {
  type = bool
  default = true
}

variable "is_ipv6_enabled" {
  type = bool
  default = true
}

variable "domain_name" {
  type = string
  default = null
}

variable "acm_certificate_arn" {
  type = string
  default = null
  description = "Required when using a domain name"
}

variable "tags" {
  type = map(string)
  default = {}
}
