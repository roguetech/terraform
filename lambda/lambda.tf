data "aws_sns_topic" "Default_CloudWatch_Alarms_Topic" {
	name = "Default_CloudWatch_Alarms_Topic"
}

resource "aws_lambda_function" "time_test" {
  filename      = "timetest.zip"
  function_name = "timetest"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "index.js"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${filebase64sha256("timetest.zip")}"

  runtime = "nodejs12.x"

  environment {
    variables = {
      name = "timetest"
    }
  }
}

resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
}

resource "aws_sns_topic_subscription" "user_updates_lambda_target" {
  topic_arn = data.aws_sns_topic.Default_CloudWatch_Alarms_Topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.time_test.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "${aws_iam_policy.lambda_dynamodb.arn}"
}
