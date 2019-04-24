data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "data-lake" {
  bucket = "data-lake-twitter"
  acl    = "private"
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["firehose.amazonaws.com", "kinesis.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "firehose_role" {
  role = "${aws_iam_role.firehose_role.name}"

  policy = <<EOF
{
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["${aws_s3_bucket.data-lake.arn}"]
    },
    {
      "Effect": "Allow",
      "Action": "kinesis:*",
      "Resource": [
          "arn:aws:kinesis:${var.region}:${data.aws_caller_identity.current.account_id}:stream/${aws_kinesis_stream.twitter.name}"
      ]
    }
  ]
}
EOF
}
