#!/bin/bash

XAI_KEY="$1"

SUBNET_IDS=$(cd Terraform/sb && terraform output  -json private_ips | jq -r 'join(",")')

echo $SUBNET_IDS
aws eks update-kubeconfig --region us-east-1 --name prod-eks-cluster
kubectl config set-context --current --namespace=prod

kubectl apply -f k8s/prod/roles

kubectl apply -f k8s/prod/secrets.yaml
kubectl apply -f k8s/prod/backend
kubectl apply -f k8s/prod/frontend