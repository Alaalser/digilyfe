#!/bin/bash

set -e  # Exit immediately on error

# Input vars (must be passed in or set in GitHub Actions)
ECR_REGISTRY=067632295431.dkr.ecr.us-east-1.amazonaws.com
ECR_REPOSITORY=simple-http-app
IMAGE_TAG=latest
IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

# ECS Task Execution Role ARN (must be passed in or set in GitHub Actions)
ECS_EXECUTION_ROLE_ARN=${ECS_EXECUTION_ROLE_ARN:-arn:aws:iam::067632295431:role/ecsTaskExecutionRole} # Replace with your actual ECS Task Execution Role ARN

# Network configuration (must be passed in or set in GitHub Actions)
SUBNET_ID=${SUBNET_ID:?Error: SUBNET_ID not set. Please provide your actual subnet ID.}
SECURITY_GROUP_ID=${SECURITY_GROUP_ID:?Error: SECURITY_GROUP_ID not set. Please provide your actual security group ID.}

echo "Using image: $IMAGE"

# Create ECS cluster (idempotent)
aws ecs create-cluster --cluster-name simple-http-app-cluster || true

# Generate task definition with the actual image value
cat > task-definition.json <<EOF
{
  "family": "simple-http-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "${ECS_EXECUTION_ROLE_ARN}",
  "containerDefinitions": [
    {
      "name": "simple-http-app-container",
      "image": "${IMAGE}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "protocol": "tcp"
        }
      ]
    }
  ]
}
EOF

echo "Registering task definition..."
aws ecs register-task-definition --cli-input-json file://task-definition.json

echo "Creating/Updating ECS service..."

# Check if service exists
SERVICE_EXISTS=$(aws ecs describe-services --cluster simple-http-app-cluster --services simple-http-app-service --query 'services[0].status' --output text 2>/dev/null || true)

if [ "$SERVICE_EXISTS" == "ACTIVE" ]; then
  echo "Service simple-http-app-service already exists. Updating..."
  aws ecs update-service \
    --cluster simple-http-app-cluster \
    --service simple-http-app-service \
    --task-definition simple-http-app \
    --desired-count 1 \
    --force-new-deployment
else
  echo "Service simple-http-app-service does not exist. Creating..."
  aws ecs create-service \
    --cluster simple-http-app-cluster \
    --service-name simple-http-app-service \
    --task-definition simple-http-app \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[${SUBNET_ID}],securityGroups=[${SECURITY_GROUP_ID}],assignPublicIp=ENABLED}"
fi
