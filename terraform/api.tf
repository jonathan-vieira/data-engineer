resource "aws_lambda_function" "api-lambda" {
  filename      = "~/data-engineer/api.zip"
  function_name = "api-lambda"
  role          = "${aws_iam_role.lambda_iam.arn}"
  handler       = "api.main"
  runtime       = "python3.6"
  source_code_hash = "${base64sha256(file("~/data-engineer/api.zip"))}"
  memory_size      = 128
  timeout          = 60
}

resource "aws_api_gateway_rest_api" "api_gw" {
  name          = "proxy_api"
  description   = "API Gateway to talk to microservices"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gw.id}"
  parent_id   = "${aws_api_gateway_rest_api.api_gw.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id       = "${aws_api_gateway_rest_api.api_gw.id}"
  resource_id       = "${aws_api_gateway_resource.proxy.id}"
  http_method       = "GET"
  authorization     = "NONE"
  api_key_required  = true
}

resource "aws_api_gateway_integration" "proxy" {
  rest_api_id             = "${aws_api_gateway_rest_api.api_gw.id}"
  resource_id             = "${aws_api_gateway_resource.proxy.id}"
  http_method             = "${aws_api_gateway_method.proxy.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.api-lambda.arn}/invocations"
}

resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.api_gw.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"
  status_code = "200"
}

resource "aws_lambda_permission" "apigw_lambda_proxy" {
  statement_id  = "AllowExecutionFromAPIGatewayPost"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.api-lambda.arn}"
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api_gw.id}/*/*/*"
}