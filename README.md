# Simple HTTP App

You can run the applications through this [Link](http://44.201.147.142/)


## Overview
Build a small application in your favorite language (e.g., Python, Go, etc.).
It should listen on an HTTP port and respond to a GET request with "hello world".

## Containerization
Package the app in a Docker container.

## Orchestration
Provide a docker-compose.yml that runs your container.

## CI/CD Pipeline
Use your preferred CI/CD tool (e.g., GitHub Actions, GitLab CI, Jenkins) to:
- Build the Docker image.
- Run docker-compose up.
- Verify via HTTP that the app returns "hello world".

## Cloud Deployment & Security Scanning
- Deploy your Docker-Compose setup to a free-tier environment on Azure, AWS, or Google Cloud.
- Automate that deployment in your CI/CD pipeline.
- Integrate both an OWASP dependency check (or equivalent) and a container-scanning tool (e.g., Trivy or Clair) into the pipeline, and include the generated scan reports in your repo.
