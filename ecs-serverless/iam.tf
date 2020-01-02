resource "aws_iam_role" "start-timetable-solver-task-iam-role" {
  name               = "start-timetable-solver-task-iam-role"
  assume_role_policy = file("policies/lambda-assume-role.json")
}

resource "aws_iam_role" "query-status-timetable-solver-task-iam-role" {
  name               = "query-status-timetable-solver-task-iam-role"
  assume_role_policy = file("policies/lambda-assume-role.json")
}

resource "aws_iam_role" "stop-timetable-solver-task-role" {
  name               = "stop-timetable-solver-task-role"
  assume_role_policy = file("policies/lambda-assume-role.json")
}

resource "aws_iam_role_policy" "start-timetable-solver-task-iam-role-policy" {
  name   = "start-timetable-solver-task-iam-role-policy"
  role   = aws_iam_role.start-timetable-solver-task-iam-role.id
  policy = file("policies/start-timetable-solver-task-iam-role.json")
}

resource "aws_iam_role_policy" "query-status-timetable-solver-task-iam-role-policy" {
  name   = "query-status-timetable-solver-task-iam-role-policy"
  role   = aws_iam_role.query-status-timetable-solver-task-iam-role.id
  policy = file("policies/query-status-timetable-solver-task-iam-role.json")
}

resource "aws_iam_role_policy" "stop-timetable-solver-task-role-policy" {
  name   = "stop-timetable-solver-task-role-policy"
  role   = aws_iam_role.stop-timetable-solver-task-role.id
  policy = file("policies/stop-timetable-solver-task-iam-role.json")
}

data "aws_iam_policy_document" "resource-policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "execute-api:Invoke"
    ]
    resources = [
      "execute-api:/*"
    ]
  }
}
