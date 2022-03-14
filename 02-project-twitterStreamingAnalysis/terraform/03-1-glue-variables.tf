# Glue 데이터 베이스 이름
variable "database_name" {
  type = string
  default = "twitter_streaming_database"
}
# Glue 테이블 이름 - tweets
variable "tweets_tweets_table_name" {
  type = string
  default = "tweets"
}
# Glue 테이블 S3 Path - tweets
variable "tweets_tweets_compressed_s3_name" {
  type = string
  default = "s3://twitter-streaming-compressed-juiceb/tweets/"
}
# Glue 테이블 이름 - entities
variable "tweets_entities_table_name" {
  type = string
  default = "tweet_entities"
}
# Glue 테이블 S3 Path - entities
variable "tweets_entities_s3_location" {
  type = string
  default = "s3://twitter-streaming-compressed-juiceb/entities/"
}
# Glue 테이블 이름 - sentiment
variable "tweets_sentiment_table_name" {
  type = string
  default = "tweet_sentiment"
}
# Glue 테이블 S3 Path - sentiment
variable "tweets_sentiment_s3_location" {
  type = string
  default = "s3://twitter-streaming-compressed-juiceb/sentiment/"
}