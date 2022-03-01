# Lambda 역할
resource "aws_iam_role" "twitter-streaming-lambda-role" {
  name = "twitter-streaming-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
# Lambda 정책
resource "aws_iam_policy" "twitter-streaming-lambda-policy" {

  name         = "twitter-streaming-lambda-policy"
  path         = "/"
  description  = "IAM policy for logging from a lambda"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "comprehend:DetectSentiment",
                "s3:*",
                "firehose:*",
                "logs:*",
                "comprehend:DetectEntities"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# Lambda 정책-역할 연결
resource "aws_iam_role_policy_attachment" "policy_attach" {
  role        = aws_iam_role.twitter-streaming-lambda-role.name
  policy_arn  = aws_iam_policy.twitter-streaming-lambda-policy.arn
}

# Lambda Script위치
data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda/lambda_function.zip"
}


# Lambda 생성
resource "aws_lambda_function" "twitter-streaming-lambda" {
  filename                       = "${path.module}/lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_function.zip")
  function_name                  = var.twitter-streaming-lambda-function-name
  role                           = aws_iam_role.twitter-streaming-lambda-role.arn
  handler                        = "lambda_function.lambda_handler"
  runtime                        = var.twitter-streaming-lambda-function-runtime
  depends_on                     = [aws_iam_role_policy_attachment.policy_attach]
  timeout = 300
# 환경변수
  environment {
    variables = {
      ENTITY_STREAM = var.twitter-streaming-firehose-entities
      SENTIMENT_STREAM = var.twitter-streaming-firehose-sentiment
      TWEETS_STREAM = var.twitter-streaming-firehose-tweets
    }
}

# Lambda 버킷 허용 권한
}
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.twitter-streaming-lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.twitter-streaming-raw-bucket.arn
}

# S3 트리거
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3-bucket-name-raw

  lambda_function {
    lambda_function_arn = aws_lambda_function.twitter-streaming-lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw/"
  }
  depends_on = [aws_lambda_permission.allow_bucket]
}