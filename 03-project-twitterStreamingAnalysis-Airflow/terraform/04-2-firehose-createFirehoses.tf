# TwitterAPI를 받고 S3에 저장할 Firehose - raw
resource "aws_kinesis_firehose_delivery_stream" "twitter-streaming-firehose-raw" {
  name        = var.twitter-streaming-firehose-raw
  destination = "extended_s3"
# S3 버킷, 버퍼
  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose-role.arn
    bucket_arn = aws_s3_bucket.twitter-streaming-raw-bucket.arn
    prefix = "raw/"
    buffer_size = 15
    buffer_interval = 300
  }
}
# Firehose - raw - role
resource "aws_iam_role" "firehose_role-raw" {
  name = "firehose-role-raw"
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "firehose.amazonaws.com"]}}]}
EOF
}


# Lambda에서 받고 s3로 넣을 Firehose - entities
resource "aws_kinesis_firehose_delivery_stream" "twitter-streaming-firehose-entities" {
  name        = var.twitter-streaming-firehose-entities
  destination = "extended_s3"
# S3 버킷, 버퍼
  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose-role.arn
    bucket_arn = aws_s3_bucket.twitter-streaming-compressed-bucket.arn
    prefix = "entities/"
    buffer_size = 128
    buffer_interval = 300
# Parquet 변환
    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }
# 데이터베이스 설정
      schema_configuration {
        database_name = "${aws_glue_catalog_database.twitter_streaming_database.name}"
        role_arn      = aws_iam_role.firehose-role.arn
        table_name    = var.tweets_entities_table_name
      }
  }
}
}
# Firehose - entities - role
resource "aws_iam_role" "firehose_role-entities" {
  name = "firehose-role-entities"
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "firehose.amazonaws.com"]}}]}
EOF
}


# Lambda에서 받고 s3로 넣을 Firehose - sentiments
resource "aws_kinesis_firehose_delivery_stream" "twitter-streaming-firehose-sentiment" {
  name        = var.twitter-streaming-firehose-sentiment
  destination = "extended_s3"
# S3 버킷, 버퍼
  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose-role.arn
    bucket_arn = aws_s3_bucket.twitter-streaming-compressed-bucket.arn
    prefix = "sentiment/"
    buffer_size = 128
    buffer_interval = 300
# Parquet 변환
    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }
# 데이터베이스 설정
      schema_configuration {
        database_name = "${aws_glue_catalog_database.twitter_streaming_database.name}"
        role_arn      = aws_iam_role.firehose-role.arn
        table_name    = var.tweets_sentiment_table_name
      }
  }
}
}
# Firehose - sentiment - role
resource "aws_iam_role" "firehose_role" {
  name = "firehose-role-sentiment"
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "firehose.amazonaws.com"]}}]}
EOF
}

# Lambda에서 받고 s3로 넣을 Firehose - tweets
resource "aws_kinesis_firehose_delivery_stream" "twitter-streaming-firehose-raw-compressed" {
  name        = var.twitter-streaming-firehose-tweets
  destination = "extended_s3"
# S3 버킷, 버퍼
  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose-role.arn
    bucket_arn = aws_s3_bucket.twitter-streaming-compressed-bucket.arn
    prefix = "tweets/"
    buffer_size = 128
    buffer_interval = 300
# Parquet 변환
    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          hive_json_ser_de {}
        }
      }

      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }
# 데이터베이스 설정
      schema_configuration {
        database_name = "${aws_glue_catalog_database.twitter_streaming_database.name}"
        role_arn      = aws_iam_role.firehose-role.arn
        table_name    = var.tweets_tweets_table_name
      }
  }
}
}
# Firehose - tweets - role
resource "aws_iam_role" "firehose_role-tweets" {
  name = "firehose-role-tweets"
 assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "firehose.amazonaws.com"]}}]}
EOF
}
