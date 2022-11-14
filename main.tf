
/*module "backup" {
  source = "./module/backup"
  email = var.email
  account = var.account
  s3_bucket_lambda = var.s3_bucket_lambda
}
*/

module "vault-install" {
  source = "./module/install"
}

module "vault-restore-lambda" {
  source = "./module/lambda"
}

module "eventbridge" {
  source = "./module/eventbridge"
  lambda-arn = module.vault-restore-lambda.lambda-arn
  lambda-name = module.vault-restore-lambda.lambda-name
}