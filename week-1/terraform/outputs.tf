# Output values for deployed infrastructure


output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = var.use_elastic_ip ? aws_eip.app_server[0].public_ip : aws_instance.app_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

output "application_url" {
  description = "URL to access the application"
  value       = "http://${var.use_elastic_ip ? aws_eip.app_server[0].public_ip : aws_instance.app_server.public_ip}:5000"
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.app_server.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i devops-key.pem ec2-user@${var.use_elastic_ip ? aws_eip.app_server[0].public_ip : aws_instance.app_server.public_ip}"
}

output "private_key" {
  description = "Private SSH key (save this securely)"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/devops-internship/hello-world"
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "deployment_summary" {
  description = "Summary of the deployment"
  value = <<-EOT
    
    Instance ID:       ${aws_instance.app_server.id}
    Public IP:         ${var.use_elastic_ip ? aws_eip.app_server[0].public_ip : aws_instance.app_server.public_ip}
    Application URL:   http://${var.use_elastic_ip ? aws_eip.app_server[0].public_ip : aws_instance.app_server.public_ip}:5000
    SSH Command:       ssh -i devops-key.pem ec2-user@${var.use_elastic_ip ? aws_eip.app_server[0].public_ip : aws_instance.app_server.public_ip}
    Region:            ${var.aws_region}
    Instance Type:     ${var.instance_type}
    
    Wait 2-3 minutes for application to be fully ready
    
    To get your SSH key:
    terraform output -raw private_key > devops-key.pem
    chmod 400 devops-key.pem
    
    To test the application:
    curl http://${var.use_elastic_ip ? aws_eip.app_server[0].public_ip : aws_instance.app_server.public_ip}:5000
    
    Remember to destroy resources when done:
    terraform destroy
    
  EOT
}