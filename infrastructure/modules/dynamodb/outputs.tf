output "table_names" {
  description = "Map of logical name to DynamoDB table name"
  value = {
    users                  = aws_dynamodb_table.users.name
    user_settings          = aws_dynamodb_table.user_settings.name
    portfolio_holdings     = aws_dynamodb_table.portfolio_holdings.name
    portfolio_transactions = aws_dynamodb_table.portfolio_transactions.name
    journal_entries        = aws_dynamodb_table.journal_entries.name
    alerts                 = aws_dynamodb_table.alerts.name
    watchlist              = aws_dynamodb_table.watchlist.name
    device_tokens          = aws_dynamodb_table.device_tokens.name
    ws_connections         = aws_dynamodb_table.ws_connections.name
  }
}

output "table_arns" {
  description = "List of all DynamoDB table ARNs (and their indexes) for IAM policies"
  value = concat(
    [
      aws_dynamodb_table.users.arn,
      aws_dynamodb_table.user_settings.arn,
      aws_dynamodb_table.portfolio_holdings.arn,
      aws_dynamodb_table.portfolio_transactions.arn,
      aws_dynamodb_table.journal_entries.arn,
      aws_dynamodb_table.alerts.arn,
      aws_dynamodb_table.watchlist.arn,
      aws_dynamodb_table.device_tokens.arn,
      aws_dynamodb_table.ws_connections.arn,
    ],
    [
      "${aws_dynamodb_table.alerts.arn}/index/*",
      "${aws_dynamodb_table.ws_connections.arn}/index/*",
    ]
  )
}
