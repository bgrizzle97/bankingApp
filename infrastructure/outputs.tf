# High-Security Banking Application Infrastructure Outputs
# Phase 1: Foundation & Core Infrastructure

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "eks_cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.main.name
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "eks_node_group_id" {
  description = "ID of the EKS node group"
  value       = aws_eks_node_group.main.id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.main.arn
}

output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "rds_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IP of the bastion host"
  value       = aws_instance.bastion.private_ip
}

output "kms_key_arn" {
  description = "ARN of the KMS key for EKS encryption"
  value       = aws_kms_key.eks.arn
}

output "security_group_ids" {
  description = "IDs of all security groups"
  value = {
    alb       = aws_security_group.alb.id
    application = aws_security_group.application.id
    database  = aws_security_group.database.id
    bastion   = aws_security_group.bastion.id
  }
}

output "iam_role_arns" {
  description = "ARNs of IAM roles"
  value = {
    ecs_task_execution = aws_iam_role.ecs_task_execution.arn
    eks_cluster        = aws_iam_role.eks_cluster.arn
    eks_node_group     = aws_iam_role.eks_node_group.arn
    rds_monitoring     = aws_iam_role.rds_monitoring.arn
  }
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "route_table_ids" {
  description = "IDs of route tables"
  value = {
    public  = aws_route_table.public.id
    private = aws_route_table.private.id
  }
}

output "db_subnet_group_name" {
  description = "Name of the RDS subnet group"
  value       = aws_db_subnet_group.main.name
}

output "db_parameter_group_name" {
  description = "Name of the RDS parameter group"
  value       = aws_db_parameter_group.main.name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = aws_eks_cluster.main.platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.main.status
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.main.status
}

output "node_group_resources" {
  description = "Resources of the EKS node group"
  value       = aws_eks_node_group.main.resources
}

output "rds_instance_status" {
  description = "Status of the RDS instance"
  value       = aws_db_instance.main.status
}

output "rds_instance_availability_zone" {
  description = "Availability zone of the RDS instance"
  value       = aws_db_instance.main.availability_zone
}

output "rds_instance_storage_encrypted" {
  description = "Whether the RDS instance storage is encrypted"
  value       = aws_db_instance.main.storage_encrypted
}

output "rds_instance_backup_retention_period" {
  description = "Backup retention period of the RDS instance"
  value       = aws_db_instance.main.backup_retention_period
}

output "rds_instance_performance_insights_enabled" {
  description = "Whether Performance Insights is enabled for the RDS instance"
  value       = aws_db_instance.main.performance_insights_enabled
}

output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = aws_instance.bastion.id
}

output "bastion_instance_type" {
  description = "Instance type of the bastion host"
  value       = aws_instance.bastion.instance_type
}

output "bastion_availability_zone" {
  description = "Availability zone of the bastion host"
  value       = aws_instance.bastion.availability_zone
}

# Configuration for kubectl
output "kubeconfig" {
  description = "kubectl config as generated by the module"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}

# Connection information for the application
output "connection_info" {
  description = "Connection information for the banking application"
  value = {
    alb_dns_name = aws_lb.main.dns_name
    rds_endpoint = aws_db_instance.main.endpoint
    bastion_ip   = aws_instance.bastion.public_ip
    cluster_name  = aws_eks_cluster.main.name
  }
}

# Security information
output "security_info" {
  description = "Security-related information"
  value = {
    vpc_id = aws_vpc.main.id
    security_groups = {
      alb         = aws_security_group.alb.id
      application = aws_security_group.application.id
      database    = aws_security_group.database.id
      bastion     = aws_security_group.bastion.id
    }
    kms_key_arn = aws_kms_key.eks.arn
    ssl_enabled = var.certificate_arn != ""
  }
} 