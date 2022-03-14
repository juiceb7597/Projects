# TwitterAPI를 받고 S3-uncompressed에 저장할 Firehose - raw 이름
variable "twitter-streaming-firehose-raw" {
  type = string
  default = "twitter-streaming-firehose-raw"  
}
# Lambda에서 받고 S3-compressed에 저장할 Firehose - entities 이름
variable "twitter-streaming-firehose-entities" {
  type = string
  default = "twitter-streaming-firehose-entities"  
}
# Lambda에서 받고 S3-compressed에 저장할 Firehose - sentiment 이름
variable "twitter-streaming-firehose-sentiment" {
  type = string
  default = "twitter-streaming-firehose-sentiment"  
}
# Lambda에서 받고 S3-compressed에 저장할 Firehose - tweets 이름
variable "twitter-streaming-firehose-tweets" {
  type = string
  default = "twitter-streaming-firehose-tweets"  
}