# 🏗️ CI Pipeline with Docker

This section covers how to integrate Docker into a Continuous Integration (CI) pipeline, focusing on building Docker images, running tests inside containers, using Docker in GitHub Actions, and optimizing builds with layer caching. These practices ensure consistent and reproducible builds in CI/CD workflows, which are essential for DevOps and software development. Let’s explore each topic with a practical example using a Node.js app!

## 🏗️ Sub-Topics

### 1. Building Images in CI
Building Docker images in a CI pipeline ensures that your application is packaged consistently across environments. This step typically involves creating a Dockerfile and building the image as part of the CI workflow.

#### Hands-On Example: Building a Node.js App Image
We’ll create a simple Node.js app with a Dockerfile and build it in a CI pipeline.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the CI Pipeline Demo!');
});

app.get('/health', (req, res) => {
    res.status(200).send('OK');
});

module.exports = app;

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**app.test.js**
```javascript
const request = require('supertest');
const app = require('./app');

describe('App Endpoints', () => {
    it('should return hello message on GET /', async () => {
        const res = await request(app).get('/');
        expect(res.statusCode).toEqual(200);
        expect(res.text).toBe('Hello from the CI Pipeline Demo!');
    });

    it('should return OK on GET /health', async () => {
        const res = await request(app).get('/health');
        expect(res.statusCode).toEqual(200);
        expect(res.text).toBe('OK');
    });
});
```

**package.json**
```json
{
    "name": "ci-pipeline-demo",
    "version": "1.0.0",
    "main": "app.js",
    "dependencies": {
        "express": "^4.18.2"
    },
    "devDependencies": {
        "jest": "^29.7.0",
        "supertest": "^7.0.0"
    },
    "scripts": {
        "start": "node app.js",
        "test": "jest"
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

CMD ["npm", "start"]
```

#### Building in CI
The image will be built as part of the GitHub Actions workflow (see the "Docker in GitHub Actions" section below). The `docker build` command creates an image tagged as `ci-pipeline-demo:latest`.

### 2. Running Tests in Containers
Running tests inside a Docker container ensures a consistent environment, avoiding the "works on my machine" problem. The container isolates dependencies and configurations, making tests reproducible.

#### Using the Example Above
The `package.json` includes a `test` script that runs Jest tests defined in `app.test.js`. The tests will be executed inside a Docker container during the CI pipeline.

#### How It Works
- The Dockerfile installs all dependencies, including `jest` and `supertest`.
- The CI pipeline will run the tests using a command like `docker run ci-pipeline-demo:latest npm test`.
- This ensures the tests run in the same environment as the production app.

### 3. Docker in GitHub Actions
GitHub Actions is a popular CI/CD platform that integrates seamlessly with Docker. You can use Docker commands in GitHub Actions workflows to build images, run tests, and push images to a registry.

#### Example: GitHub Actions Workflow
**ci-pipeline.yml**
```yaml
# Main Learning Points: CI Pipeline with Docker
# Build a Docker image, run tests, and push to Docker Hub with caching.

name: CI Pipeline with Docker

on:
  push:
    branches: [ main ]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      # Checkout the repository code
      - name: Checkout code
        uses: actions/checkout@v3

      # Set up Docker Buildx for caching
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # Log in to Docker Hub
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Build and cache Docker image
      - name: Build Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: false
          tags: ci-pipeline-demo:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

      # Run tests in the Docker container
      - name: Run tests
        run: docker run ci-pipeline-demo:latest npm test

      # Tag and push the image to Docker Hub
      - name: Push Docker image to Docker Hub
        run: |
          docker tag ci-pipeline-demo:latest ${{ secrets.DOCKERHUB_USERNAME }}/ci-pipeline-demo:latest
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/ci-pipeline-demo:latest

# To use this workflow:
# 1. Set up GitHub Secrets for DOCKERHUB_USERNAME and DOCKERHUB_TOKEN
# 2. Ensure app.js, app.test.js, package.json, and Dockerfile are in your repository
# 3. Place this file in .github/workflows/ci-pipeline.yml
# 4. Push to the main branch to trigger the workflow
# 5. Check the workflow logs in GitHub Actions to verify the build, test, and push steps
```

#### Key Steps Explained
- **Checkout Code:** Uses `actions/checkout@v3` to clone the repository.
- **Set Up Docker Buildx:** Enables advanced build features like caching.
- **Login to Docker Hub:** Authenticates with Docker Hub using secrets.
- **Build Docker Image:** Builds the image with caching enabled (see "Caching Docker Layers" below).
- **Run Tests:** Executes the tests inside the container.
- **Push Image:** Tags and pushes the image to Docker Hub.

### 4. Caching Docker Layers
Docker layer caching speeds up builds by reusing unchanged layers. In CI pipelines, caching can significantly reduce build times, especially for large images.

#### How It Works in the Example
The `docker/build-push-action@v5` step in the GitHub Actions workflow uses GitHub Actions cache for Docker layers:
```yaml
cache-from: type=gha
cache-to: type=gha,mode=max
```
- `cache-from: type=gha`: Pulls cached layers from GitHub Actions cache.
- `cache-to: type=gha,mode=max`: Stores all layers in the cache for future builds.
- This ensures that unchanged layers (e.g., `npm install`) are reused, speeding up subsequent builds.

#### Dockerfile Optimization for Caching
The Dockerfile is structured to maximize caching:
- `COPY package*.json ./` and `RUN npm install` are placed before `COPY . .` to cache dependencies unless `package.json` changes.
- This means that code changes in `app.js` or `app.test.js` won’t trigger a rebuild of the `npm install` layer.

#### Test the Caching
1. Push an initial commit to trigger the workflow (it will build and cache the layers).
2. Make a small change to `app.js` (e.g., update the hello message) and push again.
3. Check the workflow logs in GitHub Actions—the `npm install` step should be skipped due to caching.

## 🚀 Getting Started

To set up this CI pipeline:
1. Add `app.js`, `app.test.js`, `package.json`, and `Dockerfile` to your repository.
2. Create a `.github/workflows/` directory and add `ci-pipeline.yml`.
3. Set up GitHub Secrets for `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`.
4. Push to the `main` branch to trigger the workflow.
5. Monitor the workflow in the GitHub Actions tab to verify the build, test, and push steps.
6. Check Docker Hub to confirm the image was pushed.

This CI pipeline demonstrates how to integrate Docker into your workflows, ensuring consistent builds and tests. Move on to the next sections of the roadmap to explore continuous deployment, advanced Docker concepts, and more!