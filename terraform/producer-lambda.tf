resource "aws_lambda_function" "producer-lambda" {
  filename      = "~/data-engineer/lambda.zip"
  function_name = "producer-lambda"
  role          = "${aws_iam_role.lambda_iam.arn}"
  handler       = "twitter.main"
  runtime       = "python3.6"
  source_code_hash = "${base64sha256(file("~/data-engineer/lambda.zip"))}"
  memory_size      = 256
  timeout          = 120
  environment = {
    variables = {
        consumer_key = "${var.consumer_key}",
        consumer_secret = "${var.consumer_secret}",
        access_token_key =  "${var.access_token_key}",
        access_token_secret =  "${var.access_token_secret}"
    }
}
}

resource "aws_cloudwatch_event_rule" "every_five_minutes" {
    name = "every-five-minutes"
    description = "Fires every five minutes"
    schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_five_minutes" {
    rule = "${aws_cloudwatch_event_rule.every_five_minutes.name}"
    target_id = "producer-lambda"
    arn = "${aws_lambda_function.producer-lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.producer-lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_five_minutes.arn}"
}

resource "aws_iam_role" "lambda_iam" {
  name = "lambda_iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com",
          "apigateway.amazonaws.com",
          "kinesis.amazonaws.com",
          "dynamodb.amazonaws.com"
        ]      
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "access_policy" {
  name = "lambda-access-policy"
  role = "${aws_iam_role.lambda_iam.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "dynamodb:*",
            "Resource": [
                "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${aws_dynamodb_table.twitter-dynamodb-table.name}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "kinesis:*",
            "Resource": [
                "arn:aws:kinesis:${var.region}:${data.aws_caller_identity.current.account_id}:stream/${aws_kinesis_stream.twitter.name}"
            ]
        },
                {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::*"
            ]
        }
    ]
}
EOF
}