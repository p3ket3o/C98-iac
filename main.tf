data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

# ECR repository
module "ecr" {
    source = "./modules/ecr"
    ecr_name = var.ecr_name
}

# Application Load balancer and DNS record
module "alb" {
    source = "./modules/alb"
    name = "production"
    security_group = [aws_security_group.alb.id]
    subnet = data.aws_subnet_ids.default.ids
    domain_name = var.domain_name
}
# EFS volume for mount upload files
module "efs" {
    source = "./modules/efs"
    subnet = data.aws_subnet_ids.default.ids
    security_group = [aws_security_group.efs.id]
}

# ECS services

module "ecs" {
    source = "./modules/ecs"
    cluster_name = "production"
    task_family = "C98_files"
    image_url = module.ecr.repository_url
    execution_role_arn = aws_iam_role.C98EcsTaskExecutionRole.arn
    vpc_id = data.aws_vpc.default.id
    listerner_rule = module.alb.https_arn
    backend_dns = var.backend_dns
    auth_token = var.auth_token
    subnet = data.aws_subnet_ids.default.ids
    security_groups = [aws_security_group.ec2.id]
    efs_id = module.efs.efs_id
}