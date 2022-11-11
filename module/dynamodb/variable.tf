variable "install" {
  type = bool
  default = false
}

variable "dynamodb-table" {
  description = "DynamoDB table name"
  type        = string
  default     = "vault-table"
}

variable "dynamo-read-write" {
  description = "Read / Write value"
  default     = 1
}