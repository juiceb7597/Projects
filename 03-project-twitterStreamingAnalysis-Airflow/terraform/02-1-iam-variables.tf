# Firehose용 정책 이름
variable "firehose-policy" {
  type = string
  default = "firehose-policy"  
}
# Firehose용 역할 이름
variable "firehose-role" {
  type = string
  default = "firehose-role"  
}