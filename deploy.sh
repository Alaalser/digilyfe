#!/bin/bash

# Create an ECS cluster
aws ecs create-cluster --cluster-name simple-http-app-cluster

# Create a task definition
aws ecs register-task-definition --cli-input-json file://task-definition.json

# Create a service
aws ecs create-service --cluster simple-http-app-cluster --service-name simple-http-app-service --task-definition simple-http-app --desired-count 1 --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxxxxx],securityGroups=[sg-xxxxxxxx]}"
