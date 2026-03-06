#!/bin/bash
set -e

# Terraformの出力を取得
cd infra
ECR_REPO_URL=$(terraform output -raw ecr_repository_url)
ALB_DNS_NAME=$(terraform output -raw alb_dns_name)
cd ..

AWS_REGION="ap-northeast-1"
# クラスター名とサービス名はTerraformコード内の固定値から取得
ECS_CLUSTER="miniecs-cluster"
ECS_SERVICE="miniecs-service"

echo "Logging in to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO_URL

echo "Building Docker image..."
docker build -t miniecs-app ./app

echo "Tagging Docker image..."
docker tag miniecs-app:latest $ECR_REPO_URL:latest

echo "Pushing Docker image to ECR..."
docker push $ECR_REPO_URL:latest

echo "Forcing new deployment of ECS service..."
aws ecs update-service --cluster $ECS_CLUSTER --service $ECS_SERVICE --force-new-deployment --region $AWS_REGION

echo "--------------------------------------------------"
echo "Deployment initiated successfully!"
echo "Access your app at: http://$ALB_DNS_NAME"
echo "--------------------------------------------------"