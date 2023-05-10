# Create ECR for contain docker images
resource "aws_ecr_repository" "this" {
  name = var.ecr_name
}

# Create ECR policy to remove old images
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

    policy = <<EOF
    {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Expire images older than 7 days",
                "selection": {
                    "tagStatus": "untagged",
                    "countType": "sinceImagePushed",
                    "countUnit": "days",
                    "countNumber": 7
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }
    EOF
}