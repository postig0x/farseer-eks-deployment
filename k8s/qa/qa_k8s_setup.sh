#!/bin/bash

XAI_KEY="$1"

SUBNET_IDS=$(cd Terraform/sb && terraform output  -json private_ips | jq -r 'join(",")')

echo $SUBNET_IDS
kubectl create namespace qa || echo "Namespace qa already exists"
kubectl config set-context --current --namespace=qa
aws eks update-kubeconfig --region us-east-1 --name qa-eks-cluster

# kubectl apply -f k8s/sb/roles/dev_role_binding.yaml
# kubectl apply -f k8s/sb/roles/admin_role_binding.yaml


kubectl apply -f k8s/qa/secrets.yaml
kubectl apply -f k8s/qa/backend
kubectl apply -f k8s/qa/frontend