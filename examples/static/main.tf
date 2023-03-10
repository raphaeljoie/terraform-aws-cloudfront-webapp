module "webapp" {
  source  = "../../"

  lambda_qualified_arn = "arn:lol"

  s3_bucket_name = "testbucketilestbeletbon"
  create_s3_bucket = true

  paths = [
    {
      type = "static"
      path = "_next/static/*"
    }
  ]

  default_path = {
    type = "static"
  }
}
