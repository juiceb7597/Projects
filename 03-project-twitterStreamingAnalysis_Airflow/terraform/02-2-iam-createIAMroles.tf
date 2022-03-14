# Firehose 생성 시 s3bucket role_arn용 정책
resource "aws_iam_role_policy" "firehose-policy" {
  name = var.firehose-policy
  role = aws_iam_role.firehose-role.id
  policy = jsonencode(
# s3, glue, lambda, kinesis, cloudwatch_log
{
  "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": ["*"]
            },
        {
            "Effect": "Allow",
            "Action": [
                "glue:*",
            ],
            "Resource": ["*"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:GetFunctionConfiguration"
            ],
            "Resource": ["*"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": ["*"]
        },
        {
            "Effect": "Allow",
            "Action": "kinesis:*",
            "Resource": "*"
        }
            ]})
}

# Firehose 생성 시 s3bucket role_ARN용
resource "aws_iam_role" "firehose-role" {
  name = var.firehose-role
  assume_role_policy = jsonencode(
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
                    "firehose.amazonaws.com"]}}]})
}