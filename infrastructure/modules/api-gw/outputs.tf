output "rest_api_endpoint" {
  description = "Invoke URL for the REST stage"
  value       = aws_apigatewayv2_stage.rest.invoke_url
}

output "websocket_api_endpoint" {
  description = "Invoke URL for the WebSocket stage"
  value       = aws_apigatewayv2_stage.ws.invoke_url
}

output "rest_api_id" {
  value = aws_apigatewayv2_api.rest.id
}

output "websocket_api_id" {
  value = var.ws_api_id
}
