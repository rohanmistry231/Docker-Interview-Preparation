# 🌍 Deploying with Docker

This section covers various strategies for deploying Dockerized applications, including local environments, cloud platforms like AWS ECS and Google Cloud Platform (GCP), orchestration with Docker Swarm, and managing rolling updates and rollbacks. These deployment techniques are critical for ensuring reliable and scalable application delivery in production. Let’s explore each topic with a practical example using a Node.js app!

## 🏗️ Sub-Topics

### 1. Deploying to Local Environments
Deploying to a local environment is often the first step in testing a Dockerized application. Docker Compose is a great tool for defining and running multi-container applications locally.

#### Hands-On Example: Local Deployment with Docker Compose
We’ll deploy a simple Node.js app with a Redis dependency locally.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the Deployment Demo!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "deployment-demo",
    "version": "1.0.0",
    "main": "app.js",
    "dependencies": {
        "express": "^4.18.2"
    }
}
```

**Dockerfile**
```dockerfile
# Dockerfile for a Node.js app
FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
```

**docker-compose-local.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production

  redis:
    image: redis:6.2
    ports:
      - "6379:6379"
```

#### Steps to Deploy Locally
1. Start the services:
   ```bash
   docker-compose -f docker-compose-local.yml up -d
   ```
   - `-d` runs the containers in detached mode.
2. Verify the services are running:
   ```bash
   docker-compose -f docker-compose-local.yml ps
   ```
   Output:
   ```
   Name                     Command               State           Ports
   --------------------------------------------------------------------------------
   app_1     docker-entrypoint.sh node app.js   Up      0.0.0.0:3000->3000/tcp
   redis_1   docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
   ```
3. Access the app at `http://localhost:3000`. You should see "Hello from the Deployment Demo!".
4. Stop the services:
   ```bash
   docker-compose -f docker-compose-local.yml down
   ```

### 2. Deploying to Cloud Platforms (AWS ECS, GCP)
Deploying to cloud platforms allows you to scale your application and leverage managed services. We’ll deploy to AWS Elastic Container Service (ECS) and Google Cloud Platform (GCP) using GitHub Actions.

#### AWS ECS Deployment
AWS ECS is a managed container orchestration service that integrates with Docker.

##### Example: GitHub Actions Workflow for ECS
**deploy-ecs.yml**
```yaml
# Main Learning Points: Deploying to AWS ECS
# Deploy a Docker image to AWS ECS using GitHub Actions.

name: Deploy to AWS ECS

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      # Checkout the repository code
      - name: Checkout code
        uses: actions/checkout@v3

      # Build Docker image
      - name: Build Docker image
        run: docker build -t deployment-demo:latest .

      # Log in to AWS ECR
      - name: Login to AWS ECR
        uses: aws-actions/amazon-ecr-login@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      # Push to AWS ECR
      - name: Push to AWS ECR
        run: |
          docker tag deployment-demo:latest ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/deployment-demo:latest
          docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/deployment-demo:latest

      # Deploy to ECS
      - name: Deploy to ECS
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: task-definition.json
          service: deployment-demo-service
          cluster: deployment-demo-cluster
          wait-for-service-stability: true
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

# To use this workflow:
# 1. Set up GitHub Secrets for AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_ACCOUNT_ID
# 2. Create an ECR repository, ECS cluster, and service in AWS
# 3. Define a task-definition.json file in your repository (or use AWS CLI to create it)
# 4. Place this file in .github/workflows/deploy-ecs.yml
# 5. Push to the main branch to trigger the deployment
```

##### Notes
- You’ll need to create an ECS cluster, service, and task definition in AWS beforehand.
- The `task-definition.json` should reference the image in ECR (`${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/deployment-demo:latest`).

#### GCP Deployment
Google Cloud Run is a managed platform for running containerized applications on GCP.

##### Example: GitHub Actions Workflow for GCP
**deploy-gcp.yml**
```yaml
# Main Learning Points: Deploying to Google Cloud Run
# Deploy a Docker image to Google Cloud Run using GitHub Actions.

name: Deploy to Google Cloud Run

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      # Checkout the repository code
      - name: Checkout code
        uses: actions/checkout@v3

      # Build Docker image
      - name: Build Docker image
        run: docker build -t deployment-demo:latest .

      # Authenticate to Google Cloud
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      # Configure Docker for Google Artifact Registry
      - name: Configure Docker for Google Artifact Registry
        run: gcloud auth configure-docker us-central1-docker.pkg.dev --quiet

      # Push to Google Artifact Registry
      - name: Push to Google Artifact Registry
        run: |
          docker tag deployment-demo:latest us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/deployment-demo/deployment-demo:latest
          docker push us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/deployment-demo/deployment-demo:latest

      # Deploy to Cloud Run
      - name: Deploy to Cloud Run
        uses: google-github-actions/deploy-cloudrun@v2
        with:
          service: deployment-demo
          image: us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/deployment-demo/deployment-demo:latest
          region: us-central1

# To use this workflow:
# 1. Set up GitHub Secrets for GCP_CREDENTIALS and GCP_PROJECT_ID
# 2. Create a repository in Google Artifact Registry
# 3. Enable Cloud Run API in your GCP project
# 4. Place this file in .github/workflows/deploy-gcp.yml
# 5. Push to the main branch to trigger the deployment
```

##### Notes
- Cloud Run automatically exposes the app on a URL after deployment.
- Ensure the container listens on the port specified by the `PORT` environment variable (default is 8080, but our app uses 3000, which Cloud Run will handle).

### 3. Docker Swarm for Orchestration
Docker Swarm is Docker’s native orchestration tool for managing a cluster of Docker nodes. It allows you to deploy services, scale them, and manage updates.

#### Example: Docker Swarm Deployment
**docker-stack.yml**
```yaml
version: '3.8'

services:
  app:
    image: deployment-demo:latest
    ports:
      - "3000:3000"
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
    environment:
      - NODE_ENV=production

  redis:
    image: redis:6.2
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
```

#### Steps to Deploy with Docker Swarm
1. Initialize Docker Swarm:
   ```bash
   docker swarm init
   ```
2. Build the image locally (or pull from a registry):
   ```bash
   docker build -t deployment-demo:latest .
   ```
3. Deploy the stack:
   ```bash
   docker stack deploy -c docker-stack.yml demo-stack
   ```
4. Verify the services:
   ```bash
   docker stack services demo-stack
   ```
   Output:
   ```
   ID             NAME              MODE         REPLICAS   IMAGE                  PORTS
   abc123def456   demo-stack_app    replicated   3/3        deployment-demo:latest   *:3000->3000/tcp
   789def123abc   demo-stack_redis  replicated   1/1        redis:6.2
   ```
5. Access the app at `http://localhost:3000`.

### 4. Rolling Updates and Rollbacks
Rolling updates allow you to update a service without downtime, while rollbacks let you revert to a previous version if the update fails.

#### Rolling Update with Docker Swarm
Using the `docker-stack.yml` above, we can update the `app` service to a new image version.

##### Steps for Rolling Update
1. Build a new version of the image (e.g., update `app.js` to change the message to "Hello from Version 2!"):
   ```bash
   docker build -t deployment-demo:v2 .
   ```
2. Update the stack with the new image:
   ```bash
   docker service update --image deployment-demo:v2 demo-stack_app
   ```
   - Docker Swarm performs a rolling update, replacing containers one at a time to avoid downtime.
3. Verify the update:
   ```bash
   docker service ps demo-stack_app
   ```
   Check `http://localhost:3000` to see the updated message.

##### Rollback if Needed
If the update fails or introduces issues:
1. Roll back to the previous version:
   ```bash
   docker service rollback demo-stack_app
   ```
2. Verify the rollback:
   ```bash
   docker service ps demo-stack_app
   ```
   Check `http://localhost:3000` to confirm the original message ("Hello from the Deployment Demo!") is restored.

#### Notes on Rolling Updates
- You can control the update behavior in the `deploy` section of `docker-stack.yml`:
  ```yaml
  deploy:
    replicas: 3
    update_config:
      parallelism: 1
      delay: 10s
      failure_action: rollback
  ```
  - `parallelism: 1`: Updates one container at a time.
  - `delay: 10s`: Waits 10 seconds between updates.
  - `failure_action: rollback`: Automatically rolls back if the update fails.

## 🚀 Getting Started

To deploy with Docker:
1. Start with the local deployment using `docker-compose-local.yml` to test the app.
2. Set up AWS ECS and GCP Cloud Run deployments using `deploy-ecs.yml` and `deploy-gcp.yml`, ensuring you have the necessary credentials and resources in AWS and GCP.
3. Use `docker-stack.yml` to deploy to Docker Swarm and practice orchestration.
4. Experiment with rolling updates and rollbacks in Docker Swarm to manage deployments safely.
5. Monitor the deployments to ensure they are running as expected.

These deployment strategies will help you deploy Dockerized applications reliably in various environments. Move on to the next sections of the roadmap to explore Docker Compose, advanced concepts, and more!