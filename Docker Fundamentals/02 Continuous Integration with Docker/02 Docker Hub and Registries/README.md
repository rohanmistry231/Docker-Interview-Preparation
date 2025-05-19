# 📦 Docker Hub and Registries

This section covers how to work with Docker registries, including pushing images to Docker Hub, using private registries like AWS ECR and Google Artifact Registry, tagging and versioning images, and automating image builds. These practices are essential for managing container images in CI/CD pipelines and production environments. Let’s explore each topic with a practical example using a Node.js app!

## 🏗️ Sub-Topics

### 1. Pushing Images to Docker Hub
Docker Hub is a public registry for storing and sharing Docker images. Pushing images to Docker Hub makes them accessible for deployment or sharing with others.

#### Hands-On Example: Pushing a Node.js App Image
We’ll create a simple Node.js app and push its Docker image to Docker Hub.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the Docker Registries Demo!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "docker-registries-demo",
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

#### Manual Steps to Push to Docker Hub
1. Build the image locally:
   ```bash
   docker build -t docker-registries-demo:latest .
   ```
2. Log in to Docker Hub:
   ```bash
   docker login -u YOUR_USERNAME -p YOUR_PASSWORD
   ```
   Replace `YOUR_USERNAME` and `YOUR_PASSWORD` with your Docker Hub credentials.
3. Tag the image for Docker Hub:
   ```bash
   docker tag docker-registries-demo:latest YOUR_USERNAME/docker-registries-demo:latest
   ```
4. Push the image:
   ```bash
   docker push YOUR_USERNAME/docker-registries-demo:latest
   ```
5. Verify the image on Docker Hub by visiting `https://hub.docker.com/r/YOUR_USERNAME/docker-registries-demo`.

#### Automating the Push (See "Automating Image Builds" Below)
We’ll automate this process using a GitHub Actions workflow.

### 2. Private Registries (AWS ECR, Google Artifact Registry)
Private registries like AWS Elastic Container Registry (ECR) and Google Artifact Registry provide secure storage for Docker images, often used in enterprise environments.

#### AWS ECR
AWS ECR is a managed Docker registry service integrated with AWS services like ECS and EKS.

##### Steps to Push to AWS ECR
1. Create an ECR repository:
   ```bash
   aws ecr create-repository --repository-name docker-registries-demo --region us-east-1
   ```
2. Authenticate Docker with ECR:
   ```bash
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
   ```
   Replace `<AWS_ACCOUNT_ID>` with your AWS account ID.
3. Tag the image for ECR:
   ```bash
   docker tag docker-registries-demo:latest <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/docker-registries-demo:latest
   ```
4. Push the image:
   ```bash
   docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/docker-registries-demo:latest
   ```

#### Google Artifact Registry
Google Artifact Registry is a managed registry for storing container images, integrated with Google Cloud services.

##### Steps to Push to Google Artifact Registry
1. Create a repository in Artifact Registry:
   ```bash
   gcloud artifacts repositories create docker-registries-demo --repository-format=docker --location=us-central1
   ```
2. Authenticate Docker with Artifact Registry:
   ```bash
   gcloud auth configure-docker us-central1-docker.pkg.dev
   ```
3. Tag the image for Artifact Registry:
   ```bash
   docker tag docker-registries-demo:latest us-central1-docker.pkg.dev/<PROJECT_ID>/docker-registries-demo/docker-registries-demo:latest
   ```
   Replace `<PROJECT_ID>` with your Google Cloud project ID.
4. Push the image:
   ```bash
   docker push us-central1-docker.pkg.dev/<PROJECT_ID>/docker-registries-demo/docker-registries-demo:latest
   ```

#### Automating Pushes to Private Registries
The GitHub Actions workflow below (`push-to-registries.yml`) automates pushing to Docker Hub, AWS ECR, and Google Artifact Registry.

**push-to-registries.yml**
```yaml
# Main Learning Points: Pushing to Multiple Registries
# Build and push a Docker image to Docker Hub, AWS ECR, and Google Artifact Registry.

name: Push to Registries

on:
  push:
    branches: [ main ]

jobs:
  push-to-registries:
    runs-on: ubuntu-latest
    steps:
      # Checkout the repository code
      - name: Checkout code
        uses: actions/checkout@v3

      # Build Docker image
      - name: Build Docker image
        run: docker build -t docker-registries-demo:latest .

      # Push to Docker Hub
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      - name: Push to Docker Hub
        run: |
          docker tag docker-registries-demo:latest ${{ secrets.DOCKERHUB_USERNAME }}/docker-registries-demo:latest
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/docker-registries-demo:latest

      # Push to AWS ECR
      - name: Login to AWS ECR
        uses: aws-actions/amazon-ecr-login@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Push to AWS ECR
        run: |
          docker tag docker-registries-demo:latest ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/docker-registries-demo:latest
          docker push ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com/docker-registries-demo:latest

      # Push to Google Artifact Registry
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v2
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}

      - name: Configure Docker for Google Artifact Registry
        run: gcloud auth configure-docker us-central1-docker.pkg.dev --quiet

      - name: Push to Google Artifact Registry
        run: |
          docker tag docker-registries-demo:latest us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/docker-registries-demo/docker-registries-demo:latest
          docker push us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/docker-registries-demo/docker-registries-demo:latest

# To use this workflow:
# 1. Set up GitHub Secrets for DOCKERHUB_USERNAME, DOCKERHUB_TOKEN, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_ACCOUNT_ID, GCP_CREDENTIALS, and GCP_PROJECT_ID
# 2. Ensure app.js, package.json, and Dockerfile are in your repository
# 3. Create repositories in AWS ECR and Google Artifact Registry
# 4. Place this file in .github/workflows/push-to-registries.yml
# 5. Push to the main branch to trigger the workflow
```

### 3. Tagging and Versioning Images
Tagging and versioning images ensure that you can track different versions of your application and roll back if needed.

#### Tagging Best Practices
- Use meaningful tags (e.g., `latest`, `v1.0.0`, `prod`, `dev`).
- Include version numbers for releases (e.g., `v1.0.0`).
- Use timestamps or commit SHAs for CI builds (e.g., `20250518`, `abc123`).

#### Example: Tagging with a Timestamp
Given the current date (May 18, 2025), we can tag the image with a timestamp:
```bash
docker tag docker-registries-demo:latest YOUR_USERNAME/docker-registries-demo:20250518
docker push YOUR_USERNAME/docker-registries-demo:20250518
```

#### Example: Tagging with a Version
For a release version:
```bash
docker tag docker-registries-demo:latest YOUR_USERNAME/docker-registries-demo:v1.0.0
docker push YOUR_USERNAME/docker-registries-demo:v1.0.0
```

#### Automating Tagging in CI
The `push-to-registries.yml` workflow above tags the image as `latest`. You can modify it to include version tags:
```yaml
- name: Push to Docker Hub with Version
  run: |
    docker tag docker-registries-demo:latest ${{ secrets.DOCKERHUB_USERNAME }}/docker-registries-demo:v1.0.0
    docker push ${{ secrets.DOCKERHUB_USERNAME }}/docker-registries-demo:v1.0.0
```

### 4. Automating Image Builds
Automating image builds ensures that your Docker images are always up-to-date with your codebase. This can be done using CI/CD tools like GitHub Actions.

#### Example: Automating Builds with GitHub Actions
**auto-build.yml**
```yaml
# Main Learning Points: Automating Image Builds
# Automatically build and push a Docker image on code changes or a schedule.

name: Automated Docker Build

on:
  push:
    branches: [ main ]
  schedule:
    # Run every day at 10:03 PM IST (4:33 PM UTC)
    - cron: '33 16 * * *'

jobs:
  automated-build:
    runs-on: ubuntu-latest
    steps:
      # Checkout the repository code
      - name: Checkout code
        uses: actions/checkout@v3

      # Build Docker image
      - name: Build Docker image
        run: docker build -t docker-registries-demo:latest .

      # Log in to Docker Hub
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Tag with timestamp
      - name: Tag with timestamp
        run: |
          TIMESTAMP=$(date +%Y%m%d)
          docker tag docker-registries-demo:latest ${{ secrets.DOCKERHUB_USERNAME }}/docker-registries-demo:$TIMESTAMP

      # Push to Docker Hub
      - name: Push to Docker Hub
        run: |
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/docker-registries-demo:latest
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/docker-registries-demo:$TIMESTAMP

# To use this workflow:
# 1. Set up GitHub Secrets for DOCKERHUB_USERNAME and DOCKERHUB_TOKEN
# 2. Ensure app.js, package.json, and Dockerfile are in your repository
# 3. Place this file in .github/workflows/auto-build.yml
# 4. The workflow will run on push to main or daily at 10:03 PM IST
```

#### Key Points
- **Trigger on Push:** The workflow runs whenever code is pushed to the `main` branch.
- **Scheduled Builds:** The `schedule` event runs the workflow daily at 10:03 PM IST (4:33 PM UTC, calculated as IST - 5:30 hours).
- **Dynamic Tagging:** The image is tagged with a timestamp (`20250518` for May 18, 2025) using `$(date +%Y%m%d)`.

## 🚀 Getting Started

To work with Docker registries:
1. Add `app.js`, `package.json`, and `Dockerfile` to your repository.
2. Create a `.github/workflows/` directory and add `push-to-registries.yml` and `auto-build.yml`.
3. Set up GitHub Secrets for `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_ACCOUNT_ID`, `GCP_CREDENTIALS`, and `GCP_PROJECT_ID`.
4. Create repositories in AWS ECR and Google Artifact Registry.
5. Push to the `main` branch to trigger the workflows.
6. Monitor the workflows in the GitHub Actions tab to verify the build and push steps.
7. Check Docker Hub, AWS ECR, and Google Artifact Registry to confirm the images were pushed.

These registry practices will help you manage Docker images effectively in CI/CD pipelines. Move on to the next sections of the roadmap to explore continuous deployment, advanced Docker concepts, and more!