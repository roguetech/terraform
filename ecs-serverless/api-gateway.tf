resource "aws_api_gateway_rest_api" "timetable-solver-api" {
  name = "timetable-solver-api"
  description = "Timetable Solver Gateway"
  endpoint_configuration {
      types = ["REGIONAL"]
    }
    policy = "${data.aws_iam_policy_document.resource-policy.json}"
  }
