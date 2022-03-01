# 압축 전 저장 버킷
resource "aws_s3_bucket" "twitter-streaming-raw-bucket" {
  bucket = var.s3-bucket-name-raw
}
# 압축 후 저장 버킷
resource "aws_s3_bucket" "twitter-streaming-compressed-bucket" {
  bucket = var.s3-bucket-name-compressed
}