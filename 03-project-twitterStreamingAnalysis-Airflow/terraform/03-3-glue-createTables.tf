# Glue 테이블 - tweets
resource "aws_glue_catalog_table" "twitter_stream_tweets_table" {
  name          = var.tweets_tweets_table_name
  database_name = "${aws_glue_catalog_database.twitter_streaming_database.name}"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL         = "TRUE"
    "classification" = "parquet"
  }

# 테이블 속성
  storage_descriptor {
    location      = var.tweets_tweets_compressed_s3_name
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }
# 테이블 스키마 - tweets
    columns {
      name = "created_at"
      type = "string"
    }
    columns {
      name = "text"
      type = "string"
    }
    columns {
      name    = "name"
      type    = "string"
    }
    columns {
      name    = "screen_name"
      type    = "string"
    }
    columns {
      name    = "description"
      type    = "string"
    }
    columns {
      name    = "id"
      type    = "string"
    }
    columns {
      name    = "followers"
      type    = "bigint"
    }
    columns {
      name    = "friends"
      type    = "bigint"
    }
    columns {
      name    = "source"
      type    = "string"
    }
    columns {
      name    = "lang"
      type    = "string"
    }
    columns {
      name    = "location"
      type    = "string"
    }
    columns {
      name    = "truncated"
      type    = "boolean"
    }
    columns {
      name    = "filter_level"
      type    = "string"
    }
    columns {
      name    = "in_reply_to_screen_name"
      type    = "string"
    }
    columns {
      name    = "is_quote_status"
      type    = "boolean"
    }
  }
}

# Glue 테이블 - entities
resource "aws_glue_catalog_table" "twitter_stream_entities_table" {
  name          = var.tweets_entities_table_name
  database_name = "${aws_glue_catalog_database.twitter_streaming_database.name}"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL         = "TRUE"
    "classification" = "parquet"
  }

# 테이블 속성
  storage_descriptor {
    location      = var.tweets_entities_s3_location
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "tweitter-stream-entities"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }
# 테이블 스키마 - entities
    columns {
      name = "id"
      type = "string"
    }
    columns {
      name    = "entity"
      type    = "string"
    }
    columns {
      name    = "type"
      type    = "string"
    }
    columns {
      name    = "score"
      type    = "double"
    }
  }
}


# Glue 테이블 - sentiment
resource "aws_glue_catalog_table" "twitter_stream_sentiment_table" {
  name          = var.tweets_sentiment_table_name
  database_name = "${aws_glue_catalog_database.twitter_streaming_database.name}"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL         = "TRUE"
    "classification" = "parquet"
  }

# 테이블 속성
  storage_descriptor {
    location      = var.tweets_sentiment_s3_location
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "tweitter-stream-entities"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.format" = 1
      }
    }
# 테이블 스키마 - sentiment
    columns {
      name = "id"
      type = "string"
    }
    columns {
      name    = "text"
      type    = "string"
    }
    columns {
      name    = "sentiment"
      type    = "string"
    }
    columns {
      name    = "sentiment_pos_score"
      type    = "double"
    }
    columns {
      name    = "sentiment_neg_score"
      type    = "double"
    }
    columns {
      name    = "sentiment_neu_score"
      type    = "double"
    }
    columns {
      name    = "sentiment_mixed_score"
      type    = "double"
    }
  }
}