#!/bin/bash

XAI_KEY="$1"

SUBNET_IDS=$(cd Terraform/sb && terraform output  -json private_ips | jq -r 'join(",")')

echo $SUBNET_IDS
kubectl create namespace sb || echo "Namespace sb already exists"
kubectl config set-context --current --namespace=sb
aws eks update-kubeconfig --region us-east-1 --name sb-test

# kubectl wait --for=condition=ready nodes --all --timeout=300s
kubectl apply -f k8s/sb/roles/dev_role_binding.yaml
kubectl apply -f k8s/sb/roles/admin_role_binding.yaml


kubectl apply -f k8s/sb/secrets.yaml
kubectl apply -f k8s/sb/backend
kubectl apply -f k8s/sb/frontend


