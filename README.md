bug-free-chainsaw
=================

The Docker image has been generated from the ping-pong-api source code and uploaded to Docker Hub at the following location: mdraju1980/ping-pong-api.

To pull this image onto your local machine, execute the following command:
docker pull mdraju1980/ping-pong-api:latest


Define Provider and Variables:
-----------------------------
Specify the AWS provider and declare variables for the AWS region and EKS cluster name.

Create VPC:
-----------
Utilize the terraform-aws-modules/vpc/aws module to create a VPC, providing networking resources for the EKS cluster.

Deploy EKS Cluster:
-------------------
Use the terraform-aws-modules/eks/aws module to provision the EKS cluster, specifying the VPC ID, subnets, node group configuration, and tags.

Update Kubeconfig:
------------------
Implement a provisioner to update the local kubeconfig file with the settings of the newly deployed EKS cluster.

Deploy Kubernetes Application:
------------------------------
Deploy the ping-pong-api Kubernetes application as a deployment, ensuring a minimum of two pods and appropriate configuration.

Create a Kubernetes service to expose and publish an endpoint for /ping.

