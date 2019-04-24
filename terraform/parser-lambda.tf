resource "aws_lambda_function" "parser-lambda" {
  filename      = "~/data-engineer/parser-lambda.zip"
  function_name = "parser-lambda"
  role          = "${aws_iam_role.lambda_iam.arn}"
  handler       = "parser.main"
  runtime       = "python3.6"
  source_code_hash = "${base64sha256(file("~/data-engineer/parser-lambda.zip"))}"
  memory_size      = 256
  timeout          = 60
}

resource "aws_lambda_event_source_mapping" "trigger" {
  event_source_arn  = "${aws_kinesis_stream.twitter.arn}"
  function_name     = "${aws_lambda_function.parser-lambda.arn}"
  batch_size        = "10"
  starting_position = "LATEST"
}