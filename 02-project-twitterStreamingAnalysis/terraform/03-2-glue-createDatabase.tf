# Glue 데이터베이스 생성
resource "aws_glue_catalog_database" "twitter_streaming_database" {
  name = var.database_name
}