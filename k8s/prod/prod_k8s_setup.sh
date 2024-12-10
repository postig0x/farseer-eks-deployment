#!/bin/bash

XAI_KEY="$1"
# kubectl wait --for=condition=ready nodes --all --timeout=300s

# Creating the nodegroup for the cluster
eksctl create nodegroup --cluster prod-eks-cluster --name prod-eks-nodegroup --node-type t3.micro --nodes 2 --nodes-min 1 --nodes-max 10

# Associate IAM OIDC provider
eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=prod-eks-cluster --approve

# Create IAM service account
eksctl create iamserviceaccount \
  --cluster=prod-eks-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::194722418902:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

# Install cert-manager first and ensure it's ready
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml

# Wait for cert-manager to be ready - increased timeout and added verification
echo "Waiting for cert-manager pods to be ready..."
kubectl wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=300s
kubectl wait --for=condition=ready pod -l app=cainjector -n cert-manager --timeout=300s
kubectl wait --for=condition=ready pod -l app=webhook -n cert-manager --timeout=300s

# Apply CRDs first
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds"
sleep 30

# Apply the self-signed issuer first
kubectl apply -f k8s/self_signed_issuer.yaml

# Wait for issuer to be ready
sleep 10

# Apply the main controller configuration
kubectl apply -f k8s/prod/prod_v2_4_7_full.yaml

# Wait for the certificate to be ready
echo "Waiting for AWS Load Balancer Controller certificate..."
kubectl wait --for=condition=ready certificate aws-load-balancer-serving-cert -n kube-system --timeout=300s

# Wait for the controller to be ready
echo "Waiting for AWS Load Balancer Controller pods..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=aws-load-balancer-controller -n kube-system --timeout=300s

# Apply remaining resources with increased delays
kubectl apply -f k8s/ingress_class.yaml
sleep 45  # Increased delay

kubectl apply -f k8s/prod/frontend-deployment.yaml
kubectl apply -f k8s/prod/backend-deployment.yaml
sleep 45  # Increased delay

kubectl apply -f k8s/prod/frontend-service.yaml
kubectl apply -f k8s/prod/backend-service.yaml
sleep 45  # Increased delay

kubectl apply -f k8s/prod/frontend-ingress.yaml
sleep 60  # Increased delay for ingress to be processed

# Wait and get Load Balancer DNS Name
sleep 60  # Increased final wait time
#aws elbv2 describe-load-balancers --names k8s-default-kurak8de-ff2c43794b --query 'LoadBalancers[0].DNSName' --output text >> lb4.txt
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,DNSName]' --output text >> loadbalancerdns8.txt
# Add verification steps
echo "Verifying resources..."
kubectl get certificate -n kube-system
kubectl get pods -n kube-system | grep aws-load-balancer-controller
kubectl get ingress