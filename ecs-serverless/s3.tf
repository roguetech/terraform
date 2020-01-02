# Create S3 Buckets

resource "aws_s3_bucket" "timetable-solver-payload" {
  bucket = "timetable-solver-payload"
  acl    = "private"

  tags = {
    TimetableServerlessCostTag = "TimetableServerlessCostTag"
  }
}

resource "aws_s3_bucket" "timetable-serverless-state" {
  bucket = "timetable-serverless-state"
  acl    = "private"

  tags = {
    TimetableServerlessCostTag = "TimetableServerlessCostTag"
  }
}
