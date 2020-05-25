resource "aws_s3_bucket" "no-visma-inschool-production-archiving" {
  bucket = "no-visma-inschool-production-archiving"
  acl = "private"

  versioning {
    enabled = true
  }

  #logging {
  #  target_bucket = "no-visma-inschool-production-s3-buckets-logs"
  #}

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
 }
  tags = {
    "archiving" = "pdfa"
  }
}
