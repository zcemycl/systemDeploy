resource "aws_batch_compute_environment" "this" {
  compute_environment_name = "trial-spot"

  compute_resources {
    instance_role = aws_iam_instance_profile.this_ecs.arn
    instance_type = [
      "c4.large"
    ]
    max_vcpus = 16
    min_vcpus = 0

    security_group_ids = [
      aws_security_group.this.id,
    ]

    subnets = data.aws_subnets.this.ids

    type                = "SPOT"
    allocation_strategy = "SPOT_CAPACITY_OPTIMIZED"
  }

  type         = "MANAGED"
  service_role = aws_iam_role.this_batch.arn
}

resource "aws_batch_job_queue" "this" {
  name     = "trial-spot"
  state    = "ENABLED"
  priority = "0"
  compute_environments = [
    aws_batch_compute_environment.this.arn,
  ]
}

resource "aws_batch_job_definition" "this" {
  name = "trial-job-def"
  type = "container"

  container_properties = jsonencode({
    image       = aws_ecr_repository.this.repository_url
    environment = []
    resourceRequirements = [
      {
        type  = "VCPU"
        value = "1"
      },
      {
        type  = "MEMORY"
        value = "1024"
      }
    ]
    privileged = true
  })
}
