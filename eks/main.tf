terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "my-tf-state-S3-bucket"
    key            = "terraform.tfstate"
    region        = "us-west-2"
    dynamodb_table = "terraform_eks_state_locks"
    encrypt = true
  }
}
module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    eks_cluster_name = var.cluster_name
    availability_zones = var.availability_zones
    public_subnet_cidr = var.public_subnet_cidrs
    private_subnet_cidr = var.private_subnet_cidrs
}
module "eks" {
  source = "./modules/eks"
  vpc_id = module.vpc.vpc_id
  eks_cluster_name = var.cluster_name
  cluster_version = var.cluster_version
  subnet_ids = module.vpc.public_subnet_ids
  node_groups = var.node_groups
  }
  