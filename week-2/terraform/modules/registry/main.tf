variable "project_name" {
  type = string
}

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}

output "repository_url" {
  value = aws_ecr_repository.app.repository_url
}
