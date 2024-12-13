#!/bin/bash

XAI_KEY="$1"

SUBNET_IDS=$(cd Terraform/Dev && terraform output  -json private_ips | jq -r 'join(",")')

echo $SUBNET_IDS
aws eks update-kubeconfig --region us-east-1 --name dev-test-eks-cluster
kubectl config set-context --current --namespace=dev

kubectl apply -f k8s/sb/roles

kubectl apply -f k8s/dev/secrets.yaml
kubectl apply -f k8s/dev/backend
kubectl apply -f k8s/dev/frontend


