# AWS 리전
variable "aws_region" {
  type = string
  default = "ap-northeast-2"  
}
# 압축 전 S3 버킷 이름
variable "s3-bucket-name-raw" {
  type = string
  default = "twitter-streaming-raw-juiceb"
}
# 압축 후 저장 버킷 이름
variable "s3-bucket-name-compressed" {
  type = string
  default = "twitter-streaming-compressed-juiceb"  
}