resource "aws_s3_bucket" "timetable-solver-payloads" {
  bucket = "timetable-solver-payloads"
  acl    = "private"

  tags = {
    TimetableServerlessCostTag = "TimetableServerlessCostTag"
  }
}
