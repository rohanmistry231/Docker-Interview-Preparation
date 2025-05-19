# 🛠️ Third-Party Tools

This section explores how to integrate Docker with third-party tools to enhance your development and deployment workflows. You’ll learn how to use Jenkins and GitHub Actions for CI/CD, send Slack notifications for deployments, and monitor containers with Datadog. These tools are essential for automating and monitoring containerized applications. Let’s dive in with a practical example using a Node.js app!

## 🏗️ Sub-Topics

### 1. Jenkins with Docker
Jenkins is a popular CI/CD tool that can build, test, and deploy Docker containers using pipelines defined in a `Jenkinsfile`.

#### Hands-On Example: Jenkins Pipeline to Build and Deploy a Node.js App
We’ll create a Jenkins pipeline to build a Docker image, push it to Docker Hub, and deploy it locally.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the Third-Party Tools Demo!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "third-party-tools-demo",
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

**Jenkinsfile**
```groovy
pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    }
    stages {
        stage('Build') {
            steps {
                sh 'docker build -t $DOCKERHUB_CREDENTIALS_USR/third-party-tools-demo:latest .'
            }
        }
        stage('Push') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push $DOCKERHUB_CREDENTIALS_USR/third-party-tools-demo:latest'
            }
        }
        stage('Deploy') {
            steps {
                sh 'docker run -d -p 3000:3000 $DOCKERHUB_CREDENTIALS_USR/third-party-tools-demo:latest'
            }
        }
    }
}
```

#### Steps to Set Up Jenkins with Docker
1. Install Jenkins and the Docker Pipeline plugin:
   - Follow the official Jenkins installation guide for your OS.
   - Install the Docker Pipeline plugin via the Jenkins UI: Manage Jenkins > Manage Plugins.
2. Configure Docker Hub credentials in Jenkins:
   - Go to Manage Jenkins > Manage Credentials.
   - Add a new credential with ID `dockerhub-credentials` (username and password for Docker Hub).
3. Create a new pipeline job in Jenkins:
   - Select "Pipeline" as the job type.
   - In the pipeline configuration, select "Pipeline script from SCM".
   - Point it to your repository containing the `Jenkinsfile`.
4. Trigger the pipeline build:
   - The pipeline will build the Docker image, push it to Docker Hub, and deploy it locally.
5. Verify the deployment:
   ```bash
   curl http://localhost:3000
   ```
   Output:
   ```
   Hello from the Third-Party Tools Demo!
   ```

### 2. GitHub Actions with Docker
GitHub Actions automates CI/CD workflows, and you can use it to build, push, and deploy Docker images.

#### Example: GitHub Actions Workflow to Build and Push a Docker Image
We’ll create a GitHub Actions workflow to build the Node.js app image and push it to Docker Hub.

##### Supporting Files
**github-actions.yml**
```yaml
name: Build and Push Docker Image

on:
  push:
    branches: [ main ]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      # Checkout the repository code
      - name: Checkout code
        uses: actions/checkout@v3

      # Log in to Docker Hub
      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Build and push Docker image
      - name: Build and push Docker image
        run: |
          docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/third-party-tools-demo:latest .
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/third-party-tools-demo:latest
```

#### Steps to Set Up GitHub Actions with Docker
1. Set up GitHub Secrets:
   - `DOCKERHUB_USERNAME`: Your Docker Hub username.
   - `DOCKERHUB_TOKEN`: Your Docker Hub access token.
2. Place `github-actions.yml` in `.github/workflows/` in your repository.
3. Push to the `main` branch to trigger the workflow.
4. The workflow will:
   - Build the Docker image.
   - Push it to Docker Hub.
5. Verify the image on Docker Hub:
   - Check your Docker Hub repository for the `third-party-tools-demo:latest` image.

### 3. Slack Notifications for Deployment
Sending notifications to Slack after deployments keeps your team informed. We’ll use a script to send a Slack message after a deployment.

#### Example: Slack Notification Script
We’ll create a script to send a deployment notification to Slack.

##### Supporting Files
**slack-notify.sh**
```bash
#!/bin/bash

SLACK_WEBHOOK_URL="$1"
APP_NAME="third-party-tools-demo"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Send notification to Slack
curl -X POST -H 'Content-type: application/json' --data "{
    \"text\": \"Deployment completed for *${APP_NAME}* at ${TIMESTAMP}\"
}" $SLACK_WEBHOOK_URL
```

#### Steps to Send Slack Notifications
1. Create a Slack webhook:
   - Go to your Slack workspace, create an app, and enable incoming webhooks.
   - Copy the webhook URL (e.g., `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX`).
2. Make the script executable:
   ```bash
   chmod +x slack-notify.sh
   ```
3. Run the script after a deployment (e.g., after the GitHub Actions workflow):
   ```bash
   ./slack-notify.sh "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
   ```
   - The timestamp will be in UTC (IST - 5:30 hours, so 08:30 AM IST = 03:00 AM UTC).
   Example Slack Message:
   ```
   Deployment completed for *third-party-tools-demo* at 2025-05-19T03:00:00Z
   ```
4. Add the script to your CI/CD pipeline:
   - For Jenkins, add a post-build step:
     ```groovy
     post {
         always {
             sh './slack-notify.sh "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"'
         }
     }
     ```
   - For GitHub Actions, add a step:
     ```yaml
     - name: Notify Slack
       run: |
         chmod +x slack-notify.sh
         ./slack-notify.sh "${{ secrets.SLACK_WEBHOOK_URL }}"
     ```

### 4. Monitoring with Datadog
Datadog is a monitoring and analytics platform that integrates with Docker to collect metrics, logs, and traces from containers.

#### Example: Monitoring the Node.js App with Datadog
We’ll use Docker Compose to run the app with a Datadog agent.

##### Supporting Files
**docker-compose.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DD_AGENT_HOST=datadog-agent
      - DD_ENV=prod
    labels:
      - "com.datadoghq.tags.env=prod"
      - "com.datadoghq.tags.service=third-party-tools-demo"
    networks:
      - monitoring-network

  datadog-agent:
    image: datadog/agent:latest
    environment:
      - DD_API_KEY=${DD_API_KEY}
      - DD_SITE=datadoghq.com
      - DD_DOCKER_LABELS_AS_TAGS=true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /proc/:/host/proc/:ro
      - /sys/fs/cgroup/:/host/sys/fs/cgroup:ro
    networks:
      - monitoring-network

networks:
  monitoring-network:
    driver: bridge
```

#### Steps to Monitor with Datadog
1. Sign up for Datadog and get your API key:
   - Create a Datadog account and copy your API key from the Integrations > APIs section.
2. Set the API key as an environment variable:
   ```bash
   export DD_API_KEY="your-datadog-api-key"
   ```
3. Start the services:
   ```bash
   docker-compose -f docker-compose.yml up -d
   ```
   Output:
   ```
   Creating network "third-party-tools-demo_monitoring-network" with driver "bridge"
   Creating third-party-tools-demo_app_1          ... done
   Creating third-party-tools-demo_datadog-agent_1 ... done
   ```
4. Access the app to generate traffic:
   ```bash
   curl http://localhost:3000
   ```
5. Check Datadog for metrics and logs:
   - Go to Datadog > Metrics Explorer and search for `service:third-party-tools-demo`.
   - View container metrics like CPU, memory, and network usage.
   - Go to Logs to see app logs (ensure the app logs in a format Datadog can parse, e.g., JSON).
6. Create a dashboard in Datadog to visualize the app’s performance over time.

## 🚀 Getting Started

To use third-party tools with Docker:
1. Add `app.js`, `package.json`, `Dockerfile`, `Jenkinsfile`, `github-actions.yml`, `slack-notify.sh`, and `docker-compose.yml` to your project.
2. Set up Jenkins with the `Jenkinsfile` to build, push, and deploy the app.
3. Configure GitHub Actions with `github-actions.yml` to automate building and pushing the image.
4. Use `slack-notify.sh` to send deployment notifications to Slack, integrating it into your CI/CD pipelines.
5. Monitor the app with Datadog using `docker-compose.yml` and visualize metrics in the Datadog dashboard.
6. Clean up by stopping the Docker Compose services:
   ```bash
   docker-compose -f docker-compose.yml down
   ```

Third-party tools enhance your Docker workflows with automation and monitoring. Move on to the next sections of the roadmap to explore AWS integration, Kubernetes, and more!