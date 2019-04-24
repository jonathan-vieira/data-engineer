resource "aws_kinesis_stream" "twitter" {
  name             = "twitter"
  shard_count      = 1
  retention_period = 24

}


resource "aws_kinesis_firehose_delivery_stream" "firehose_stream" {
  name        = "firehose_delivery_stream"
  destination = "extended_s3"

  kinesis_source_configuration {
    kinesis_stream_arn = "${aws_kinesis_stream.twitter.arn}"
    role_arn           = "${aws_iam_role.firehose_role.arn}"
  }

  extended_s3_configuration {
    role_arn   = "${aws_iam_role.firehose_role.arn}"
    bucket_arn = "${aws_s3_bucket.data-lake.arn}"
    buffer_size     = 100
    buffer_interval = "300"

  }

}