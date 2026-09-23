resource "aws_instance" "this" {

  ami = var.ami_id

  instance_type = var.instance_type

  subnet_id = var.subnet_id

  vpc_security_group_ids = var.security_group_ids

  associate_public_ip_address = var.associate_public_ip

  key_name = var.key_name

  iam_instance_profile = var.iam_instance_profile

  monitoring = var.monitoring

  user_data = var.user_data

  root_block_device {

    volume_size = var.root_volume_size

    volume_type = var.root_volume_type

    encrypted = true

    delete_on_termination = true
  }

  metadata_options {

    http_endpoint = "enabled"

    http_tokens = "required"

    http_put_response_hop_limit = 2
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}