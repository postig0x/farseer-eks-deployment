#!/bin/bash

XAI_KEY="$1"

SUBNET_IDS=$(cd Terraform/QA && terraform output  -json private_ips | jq -r 'join(",")')

echo $SUBNET_IDS
aws eks update-kubeconfig --region us-east-1 --name qa-green
kubectl config set-context --current --namespace=qa-green

kubectl apply -f k8s/green/QA/roles

kubectl apply -f k8s/green/QA/secrets.yaml
kubectl apply -f k8s/green/QA/backend
kubectl apply -f k8s/green/QA/frontend


