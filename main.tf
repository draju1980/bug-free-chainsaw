
provider "aws" {
  region = local.region
}

# Define the AWS and EKS variables
locals {
  name   = "biconomy-cluster"
  region = "eu-west-1"

  vpc_cidr = "10.10.0.0/16"
  azs      = ["eu-west-1a", "eu-west-1b"]

  public_subnets  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets = ["10.10.3.0/24", "10.10.4.0/24"]
  intra_subnets   = ["10.10.5.0/24", "10.10.6.0/24"]

  tags = {
    Example = local.name
  }
}

# Create the VPC for EKS cluster
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnets   = local.intra_subnets

  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}


# Create the EKS cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

# EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t2.micro"]

    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    ascode-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "biconomy"
      }
    }
  }

  tags = local.tags
}



output "cluster_name" {
  value = local.name
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}


# update terraform script to update the kubeconfig file
resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region eu-west-1 update-kubeconfig --name ${local.name}"
  }
}

# update terraform script to deploy pingpong application
resource "null_resource" "deploy_pingpong" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/draju1980/bug-free-chainsaw/pingpong.yaml"
  }
}
