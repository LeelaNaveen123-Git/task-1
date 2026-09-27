output "vpc_ids" {
  value = {
    for name, vpc in module.vpc :
    name => vpc.vpc_id
  }
}

output "s3_buckets" {
  value = {
    for name, bucket in module.s3 :
    name => bucket.bucket_name
  }
}

output "ec2_instances" {
  value = {
    for name, instance in module.ec2 :
    name => {
      id         = instance.instance_id
      private_ip = instance.private_ip
      public_ip  = instance.public_ip
    }
  }
}

output "eks_clusters" {
  value = {
    for name, cluster in module.eks :
    name => {
      cluster_nasme = cluster.cluster_name
      version       = cluster.cluster_version
      endpoint      = cluster.cluster_endpoint
    }
  }
}