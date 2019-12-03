resource "aws_iam_role" "start-timetable-solver-task-iam-role" {
    name = "start-timetable-solver-task-iam-role"
    assume_role_policy = "${file("policies/start-timetable-solver-task-iam-role.json")}"
}

resource "aws_iam_role" "query-status-timetable-solver-task-iam-role" {
    name = "query-status-timetable-solver-task-iam-role"
    assume_role_policy = "${file("policies/query-status-timetable-solver-task-iam-role.json")}"
}

resource "aws_iam_role" "stop-timetable-solver-task-role" {
    name = "stop-timetable-solver-task-role"
    assume_role_policy = "${file("policies/stop-timetable-solver-task-role.json")}"
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
