#!/bin/bash

XAI_KEY="$1"

SUBNET_IDS=$(cd Terraform/sb && terraform output  -json private_ips | jq -r 'join(",")')

echo $SUBNET_IDS

# kubectl wait --for=condition=ready nodes --all --timeout=300s
kubectl apply -f k8s/sb/roles/dev_role_binding.yaml
kubectl apply -f k8s/sb/roles/admin_role_binding.yaml

# aws eks update-kubeconfig --name sb-test --region us-east-1 --profile developer
# kubectl config view --minify
# kubectl get pods
# kubectl get nodes
# aws eks update-kubeconfig --name sb-test --region us-east-1


# # Associate IAM OIDC provider
# eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=sb-test --approve
# kubectl config current-context
# kubectl create namespace sb || echo "Namespace sb already exists"
# kubectl config set-context --current --namespace=sb
# aws eks update-kubeconfig --region us-east-1 --name sb-test

# # Create IAM service account
# eksctl create iamserviceaccount \
#   --cluster=sb-test \
#   --namespace=sb \
#   --name=aws-load-balancer-controller \
#   --attach-policy-arn=arn:aws:iam::194722418902:policy/AWSLoadBalancerControllerIAMPolicy \
#   --approve

# # Install cert-manager first and ensure it's ready
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml

# # Wait for cert-manager to be ready - increased timeout and added verification
# echo "Waiting for cert-manager pods to be ready..."
# kubectl wait --for=condition=ready pod -l app=cert-manager -n cert-manager --timeout=300s
# kubectl wait --for=condition=ready pod -l app=cainjector -n cert-manager --timeout=300s
# kubectl wait --for=condition=ready pod -l app=webhook -n cert-manager --timeout=300s

# # Apply CRDs first
# kubectl apply -f https://raw.githubusercontent.com/aws/eks-charts/master/stable/aws-load-balancer-controller/crds/crds.yaml
# sleep 30

# # create xai key secret from secrets yaml
# kubectl create secret generic farseer-secret \
#   --from-literal=XAI_KEY=$XAI_KEY \
#   --dry-run=client -o yaml | kubectl apply -f - --validate=false


# kubectl apply -f k8s/sb/secrets.yaml

# # Apply the self-signed issuer first
# kubectl apply -f k8s/self_signed_issuer.yaml

# # Wait for issuer to be ready
# sleep 10

# # Apply the main controller configuration
# kubectl apply -f k8s/sb/sb_v2_4_7_full.yaml

# # Wait for the certificate to be ready
# echo "Waiting for AWS Load Balancer Controller certificate..."
# kubectl wait --for=condition=ready certificate aws-load-balancer-serving-cert -n sb --timeout=300s

# # Wait for the controller to be ready
# echo "Waiting for AWS Load Balancer Controller pods..."
# kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=aws-load-balancer-controller -n sb --timeout=300s


# # Apply remaining resources with increased delays
# kubectl apply -f k8s/ingress_class.yaml
# sleep 45  # Increased delay

# kubectl apply -f k8s/sb/frontend-deployment.yaml
# kubectl apply -f k8s/sb/backend-deployment.yaml
# sleep 45  # Increased delay

# kubectl apply -f k8s/sb/frontend-service.yaml 
# kubectl apply -f k8s/sb/backend-service.yaml
# sleep 45  # Increased delay

# kubectl apply -f k8s/sb/frontend-ingress.yaml -n sb
# sleep 60  # Increased delay for ingress to be processed

# echo "getting deployments"
# kubectl get deployments -n sb

# # wait for deployments to complete
# echo "waiting for deployments to complete"
# kubectl wait --for=condition=available --timeout=600s deployment/backend
# kubectl wait --for=condition=available --timeout=600s deployment/frontend 

# # Wait and get Load Balancer DNS Name
# sleep 60  # Increased final wait time
# #aws elbv2 describe-load-balancers --names k8s-default-kurak8de-ff2c43794b --query 'LoadBalancers[0].DNSName' --output text >> lb4.txt
# aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,DNSName]' --output text >> loadbalancerdns8.txt
# # Add verification steps
# echo "Verifying resources..."
# kubectl get certificate -n sb
# kubectl get nodes --request-timeout=5m -n sb
# kubectl get pods | grep aws-load-balancer-controller -n sb
# kubectl get services -n sb
# kubectl get ingress -n sb

# echo "checking if all pods are running"
# if kubectl get pods -n sb| grep -v Running | grep -v Completed | grep -v NAME; then
#   echo "pods are not running"
#   exit 1
# fi