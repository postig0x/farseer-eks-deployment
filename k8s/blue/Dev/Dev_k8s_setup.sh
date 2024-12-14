#!/bin/bash

XAI_KEY="$1"

SUBNET_IDS=$(cd Terraform/blue/Dev && terraform output  -json private_ips | jq -r 'join(",")')

echo $SUBNET_IDS
aws eks update-kubeconfig --region us-east-1 --name dev-blue
kubectl config set-context --current --namespace=dev-blue

kubectl apply -f k8s/blue/Dev/roles

echo "applying deployments"
kubectl apply -f k8s/blue/Dev/secrets.yaml
kubectl apply -f k8s/blue/Dev/backend
kubectl apply -f k8s/blue/Dev/frontend


