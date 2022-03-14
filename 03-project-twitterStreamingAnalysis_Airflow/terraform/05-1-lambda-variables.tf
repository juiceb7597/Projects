# Lambda 함수 이름
variable "twitter-streaming-lambda-function-name" {
  type = string
  default = "twitter-streaming-lambda"  
}
# 런타임
variable "twitter-streaming-lambda-function-runtime" {
  type = string
  default = "python3.8"  
}
