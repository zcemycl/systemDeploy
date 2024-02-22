resource "aws_ecr_repository" "this" {
  name         = "sagemaker_training_docker_invoke"
  force_delete = true
}

resource "null_resource" "this_docker" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${aws_ecr_repository.this.registry_id}.dkr.ecr.${var.AWS_REGION}.amazonaws.com >> info.txt"
  }
  provisioner "local-exec" {
    command = "docker tag ${var.local_docker_name}:latest ${aws_ecr_repository.this.repository_url}:latest >> info.txt"
  }
  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.this.repository_url}:latest >> info.txt"
  }
  depends_on = [
    aws_ecr_repository.this
  ]

  triggers = {
    always_run = "${timestamp()}"
  }
}
