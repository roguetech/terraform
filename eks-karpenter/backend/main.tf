module "s3_bucket" {
    source = "terraform-aws-modules/s3-bucket/aws"
    bucket = "terraform-bucket-calypsoai-scaling-test"
    acl = "private"

    control_object_ownership = true
    object_ownership         = "ObjectWriter"

    versioning = {
        enabled = true
    }
}

module "dynamodb" {
    source = "terraform-aws-modules/dynamodb-table/aws"
    name = "terraform-state-lock-dynamodb-01"
    hash_key = "LockID"
    attributes = [
        {
            name = "LockID"
            type = "S"
        }
    ]
    tags = {
      "Name" = "terraform-state-lock-dynamodb-01"
    }
}

module "kms" {
    source = "terraform-aws-modules/kms/aws"
    description = "KMS key for terraform state locking"

}