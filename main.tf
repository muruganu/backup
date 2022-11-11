
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