resource "aws_dynamodb_table" "vault-table" {
  count          = var.install ? 1 : 0
  name           = var.dynamodb-table
  read_capacity  = var.dynamo-read-write
  write_capacity = var.dynamo-read-write
  hash_key       = "Path"
  range_key      = "Key"
  attribute {
    name = "Path"
    type = "S"
  }

  attribute {
    name = "Key"
    type = "S"
  }


  tags = {
    backup = "true"
  }
}