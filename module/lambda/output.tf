output "lambda-arn" {
  value = aws_lambda_function.restore-vault-lambda.arn
}

output "lambda-name" {
  value = aws_lambda_function.restore-vault-lambda.function_name
}