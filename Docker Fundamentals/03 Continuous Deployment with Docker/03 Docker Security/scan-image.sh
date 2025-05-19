#!/bin/bash

# Build the image
docker build -t docker-security-demo:latest .

# Scan the image with Docker Scout
docker scout cves docker-security-demo:latest