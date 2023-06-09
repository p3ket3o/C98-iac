# IAM role for ECS task, need permission to pull ECR images
resource "aws_iam_role" "C98EcsTaskExecutionRole" {
  name = "C98EcsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.C98EcsTaskExecutionRole.name
}

# IAM user for github action to push image on ECS and reload ECS service

resource "aws_iam_user" "user" {
  name = "github-action"
}


resource "aws_iam_user_policy_attachment" "ecr_policy" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}

resource "aws_iam_user_policy_attachment" "ecs_policy" {
  user       = aws_iam_user.user.name
  policy_arn = aws_iam_policy.ecs_policy.arn
}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user.name
}

resource "aws_iam_policy" "ecr_policy" {
  name        = "ecr_policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:TagResource",
          "ecr:UntagResource",
          "ecr:BatchDeleteImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "*"
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_policy" {
  name        = "ecs_policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTask",
          "ecs:StartTelemetrySession",
          "ecs:SubmitContainerStateChange",
          "ecs:SubmitTaskStateChange",
          "ecs:StopTask",
          "ecs:UpdateContainerAgent",
          "ecs:UpdateContainerInstancesState",
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = "*"
        Effect = "Allow"
      },
      {
        Action = [
          "ec2:Describe*",
          "elasticloadbalancing:Describe*",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
        Effect = "Allow"
      }
    ]
  })
}