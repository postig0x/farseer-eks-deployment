#!/bin/bash
# user_data script for k8 manager instance

# prereqs
sudo apt install -y unzip tar

# awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

unzip awscliv2.zip && rm awscliv2.zip

sudo ./aws/install && rm -rf ./aws

#  _   ___           _             
# | |_( _ )  ___ ___| |_ _  _ _ __ 
# | / / _ \ (_-</ -_)  _| || | '_ \
# |_\_\___/ /__/\___|\__|\_,_| .__/
#                            |_|   
# kubernetes
# update repos
sudo apt update -y

# install kubectl
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.31.2/2024-11-15/bin/linux/amd64/kubectl

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

# install eksctl
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"

tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp && rm eksctl_Linux_amd64.tar.gz

sudo mv /tmp/eksctl /usr/local/bin
