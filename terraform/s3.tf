terraform {
  backend "s3" {
    bucket = "data-engineer-state"
    key    = "twitter"
    region = "us-east-1"
  }
}