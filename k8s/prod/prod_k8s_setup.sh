#!/bin/bash

XAI_KEY="$1"

SUBNET_IDS=$(cd Terraform/sb && terraform output  -json private_ips | jq -r 'join(",")')

echo $SUBNET_IDS
aws eks update-kubeconfig --region us-east-1 --name prod-eks-cluster
kubectl create namespace prod || echo "Namespace prod already exists"
kubectl config set-context --current --namespace=prod

# kubectl apply -f k8s/prod/roles/dev_role_binding.yaml
# kubectl apply -f k8s/prod/roles/admin_role_binding.yaml


kubectl apply -f k8s/prod/secrets.yaml
kubectl apply -f k8s/prod/backend
kubectl apply -f k8s/prod/frontend