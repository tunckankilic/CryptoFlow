output "api_lambda_arn" {
  value = aws_lambda_function.api.arn
}

output "api_lambda_invoke_arn" {
  value = aws_lambda_function.api.invoke_arn
}

output "api_lambda_function_name" {
  value = aws_lambda_function.api.function_name
}

output "ws_lambda_arn" {
  value = aws_lambda_function.ws_handler.arn
}

output "ws_lambda_invoke_arn" {
  value = aws_lambda_function.ws_handler.invoke_arn
}

output "ws_lambda_function_name" {
  value = aws_lambda_function.ws_handler.function_name
}

output "alert_checker_lambda_function_name" {
  value = aws_lambda_function.alert_checker.function_name
}

output "lambda_exec_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}
