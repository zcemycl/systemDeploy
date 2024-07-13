module "ecr" {
  source = "github.com/zcemycl/systemDeploy/src/tf/modules/ecr"
  region = var.AWS_REGION

  images = [
    {
      name                 = "${var.prefix}-etl1-code-server"
      lastn                = 5
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      force_delete         = true
      enable_vpc_endpt     = false
      vpc_id               = aws_vpc.this.id
      sg_ids               = []
      subnet_ids           = []
      route_table_ids      = []
    },
    {
      name                 = "${var.prefix}-etl2-code-server"
      lastn                = 5
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      force_delete         = true
      enable_vpc_endpt     = false
      vpc_id               = aws_vpc.this.id
      sg_ids               = []
      subnet_ids           = []
      route_table_ids      = []
    },
    {
      name                 = "${var.prefix}-dagster-webserver"
      lastn                = 5
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      force_delete         = true
      enable_vpc_endpt     = false
      vpc_id               = aws_vpc.this.id
      sg_ids               = []
      subnet_ids           = []
      route_table_ids      = []
    }
  ]
}

resource "null_resource" "etl1_push" {
  provisioner "local-exec" {
    command = "cd .. && docker build --platform linux/amd64 -t ${module.ecr.ecr_repo_urls["${var.prefix}-etl1-code-server"]}:latest -f codelocations/Dockerfile.user_code . --build-arg='MODULE_NAME=etl1' --build-arg='PORT=4000'"
  }
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${module.ecr.ecr_registry_ids["${var.prefix}-etl1-code-server"]}.dkr.ecr.${var.AWS_REGION}.amazonaws.com"
  }
  provisioner "local-exec" {
    command = "docker push ${module.ecr.ecr_repo_urls["${var.prefix}-etl1-code-server"]}:latest"
  }

  depends_on = [
    module.ecr
  ]
}

resource "null_resource" "etl2_push" {
  provisioner "local-exec" {
    command = "cd .. && docker build --platform linux/amd64 -t ${module.ecr.ecr_repo_urls["${var.prefix}-etl2-code-server"]}:latest -f codelocations/Dockerfile.user_code . --build-arg='MODULE_NAME=etl2' --build-arg='PORT=4001'"
  }
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${module.ecr.ecr_registry_ids["${var.prefix}-etl2-code-server"]}.dkr.ecr.${var.AWS_REGION}.amazonaws.com"
  }
  provisioner "local-exec" {
    command = "docker push ${module.ecr.ecr_repo_urls["${var.prefix}-etl2-code-server"]}:latest"
  }

  depends_on = [
    module.ecr,
    null_resource.etl1_push
  ]
}

resource "null_resource" "webserver_push" {
  provisioner "local-exec" {
    command = "cd .. && docker build --platform linux/amd64 -t ${module.ecr.ecr_repo_urls["${var.prefix}-dagster-webserver"]}:latest -f Dockerfile.dagster . --build-arg='DAGSTER_CONF=dagster-prod.yaml' --build-arg='WORKSPACE_CONF=workspace-prod.yaml'"
  }
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.AWS_REGION} | docker login --username AWS --password-stdin ${module.ecr.ecr_registry_ids["${var.prefix}-dagster-webserver"]}.dkr.ecr.${var.AWS_REGION}.amazonaws.com"
  }
  provisioner "local-exec" {
    command = "docker push ${module.ecr.ecr_repo_urls["${var.prefix}-dagster-webserver"]}:latest"
  }

  depends_on = [
    module.ecr,
    null_resource.etl2_push
  ]
}
