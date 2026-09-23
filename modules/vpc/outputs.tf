output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = {
    for az, subnet in aws_subnet.public :
    az => subnet.id
  }
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = {
    for az, subnet in aws_subnet.private :
    az => subnet.id
  }
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  value = {
    for az, subnet in aws_subnet.public :
    az => subnet.cidr_block
  }
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  value = {
    for az, subnet in aws_subnet.private :
    az => subnet.cidr_block
  }
}