resource "aws_athena_database" "twitter" {
  name   = "twitter"
  bucket = "${aws_s3_bucket.data-lake.bucket}"
}