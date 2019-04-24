resource "aws_dynamodb_table" "twitter-dynamodb-table" {
  name           = "twitter"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "twitterUser"

  attribute {
    name = "twitterUser"
    type = "S"
  }

}