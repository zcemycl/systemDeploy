resource "null_resource" "app_ecr_push" {
  triggers = {
    file1 = filemd5("../naive-3tier/src/frontend/Dockerfile")
    file2 = filemd5("../naive-3tier/src/frontend/main.py")
    file3 = filemd5("../naive-3tier/src/frontend/requirements.txt")
  }

  provisioner "local-exec" {
    command = "cd ../naive-3tier/src/frontend/ && docker build --platform linux/amd64 -t ${module.ecr.app_image}:latest -f Dockerfile ."
  }
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${module.ecr.app_repo_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  }
  provisioner "local-exec" {
    command = "docker push ${module.ecr.app_image}:latest"
  }

  depends_on = [
    module.ecr
  ]
}

resource "null_resource" "api_ecr_push" {
  triggers = {
    file1 = filemd5("./src/backend/Dockerfile")
    file2 = filemd5("./src/backend/main.py")
    file3 = filemd5("./src/backend/requirements.txt")
  }

  provisioner "local-exec" {
    command = "cd ./src/backend/ && docker build --platform linux/amd64 -t ${module.ecr.api_image}:latest -f Dockerfile ."
  }
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${module.ecr.api_repo_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  }
  provisioner "local-exec" {
    command = "docker push ${module.ecr.api_image}:latest"
  }

  depends_on = [
    module.ecr
  ]
}
