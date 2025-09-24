resource "aws_iam_role" "master_node_role" {
  name               = "${var.eks_cluster_name}-master_node_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "Master_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role = aws_iam_role.cluster_node_role.name
}
resource "aws_eks_cluster" "main" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.master_node_role.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.Master_policy,
  ]
  
}
resource "aws_iam_role" "worker_node" {
    name = "${var.eks_cluster_name}-worker_role"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        }
      ]
    })

}
resource "aws_iam_role_policy_attachment" "workers_policy" {
    for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
])

    policy_arn = each.value
    role       = aws_iam_role.worker_node.arn
}

resource "aws_eks_node_group" "main" {
    cluster_name = var.eks_cluster_name
    for_each = var.node_groups
    node_group_name = each.key
    node_role_arn = aws_iam_role.worker_node.arn
    subnet_ids = var.subnet_ids
    instance_types = each.value
    capacity_type = each.value.capacity_type
    scaling_config {
      desired_size = each.value.scaling.config.desired_size
      max_size     = each.value.scaling.config.max_size
      min_size     = each.value.scaling.config.min_size
    }
    depends_on = [ 
        aws_iam_role_policy_attachment.workers_policy
     ]
}
