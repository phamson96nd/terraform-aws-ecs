###############################
# Data source for account
###############################
data "aws_caller_identity" "current" {}

###############################
# S3 Bucket lưu artifact
###############################
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket_prefix = "${var.app_name}-pipeline-artifacts-"
  force_destroy = true

  tags = {
    Name = "${var.app_name}-pipeline-artifacts"
  }
}

###############################
# IAM Role cho CodePipeline
###############################
resource "aws_iam_role" "codepipeline_role" {
  name = "${var.app_name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Managed policy cho phép dùng CodeStar Connection
resource "aws_iam_policy" "codestar_connection_managed" {
  name = "${var.app_name}-codestar-connection"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["codestar-connections:UseConnection"]
      Resource = var.git_config.codestar_connection_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codestar_connection_attachment" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = aws_iam_policy.codestar_connection_managed.arn
}

# Inline policy cho ECS, S3, iam:PassRole, CodeBuild, CloudWatch Logs
resource "aws_iam_role_policy" "codepipeline_inline_policy" {
  name = "${var.app_name}-codepipeline-inline"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # ECS
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          # IAM
          "iam:PassRole",
          # S3
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:ListBucket",
          # CodeBuild
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds",
          "codebuild:BatchGetProjects",
          # CloudWatch Logs (CodePipeline truy xuất build logs)
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_s3_bucket.pipeline_artifacts.arn,
          "${aws_s3_bucket.pipeline_artifacts.arn}/*",
          aws_codebuild_project.build_project.arn,
          "*"
        ]
      }
    ]
  })
}

###############################
# IAM Role cho CodeBuild
###############################
resource "aws_iam_role" "codebuild_role" {
  name = "${var.app_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "codebuild.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Managed policies cho CodeBuild (ECR, S3)
resource "aws_iam_role_policy_attachment" "codebuild_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ])
  role       = aws_iam_role.codebuild_role.name
  policy_arn = each.value
}

# Inline policy CloudWatch Logs cho CodeBuild
resource "aws_iam_role_policy" "codebuild_logs_policy" {
  name = "${var.app_name}-codebuild-logs"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.app_name}-build:*"
    }]
  })
}

###############################
# CodeBuild Project
###############################
resource "aws_codebuild_project" "build_project" {
  name          = "${var.app_name}-build"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 30

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "REPONSITORY"
      value = "826895066148.dkr.ecr.ap-southeast-1.amazonaws.com"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "IMAGE"
      value = "prod-base-image"
    }

  }

  source {
    type = "CODEPIPELINE"
  }

  tags = {
    Name = "${var.app_name}-build"
  }
}

###############################
# CodePipeline
###############################
resource "aws_codepipeline" "app_pipeline" {
  name     = "${var.app_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "GitHub_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceOutput"]
      configuration = {
        ConnectionArn    = var.git_config.codestar_connection_arn
        FullRepositoryId = "${var.git_config.github_owner}/${var.git_config.github_repo}"
        BranchName       = var.git_config.github_branch
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["BuildOutput"]
      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "DeployECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["BuildOutput"]
      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.ecs_service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }

  tags = {
    Name = "${var.app_name}-pipeline"
  }
}
