#!/bin/bash

set -e  # Exit immediately on error

# Input vars (must be passed in or set in GitHub Actions)
ECR_REGISTRY=067632295431.dkr.ecr.us-east-1.amazonaws.com
ECR_REPOSITORY=simple-http-app
IMAGE_TAG=latest
IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}:${IMAGE_TAG}"

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

echo "Creating ECS service..."
aws ecs create-service \
  --cluster simple-http-app-cluster \
  --service-name simple-http-app-service \
  --task-definition simple-http-app \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxxxxx],securityGroups=[sg-xxxxxxxx],assignPublicIp=ENABLED}"
