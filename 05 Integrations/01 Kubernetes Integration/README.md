# ☸️ Kubernetes Integration

This section explores how to integrate Docker with Kubernetes for container orchestration. You’ll learn how to deploy Docker containers to Kubernetes, use Helm charts for packaging, manage Kubernetes pods and services, and set up CI/CD pipelines with Docker and Kubernetes. These techniques are essential for running scalable, production-ready applications. Let’s dive in with a practical example using a Node.js app!

## 🏗️ Sub-Topics

### 1. Deploying Docker Containers to Kubernetes
Kubernetes orchestrates Docker containers by defining resources like deployments and services. A deployment manages a set of pods (running containers), and a service exposes them to the network.

#### Hands-On Example: Deploying a Node.js App to Kubernetes
We’ll deploy a Node.js app to Kubernetes using a deployment and a service.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the Kubernetes Integration Demo!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "k8s-integration-demo",
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

**k8s-deployment.yml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: k8s-integration-demo
  labels:
    app: k8s-integration-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: k8s-integration-demo
  template:
    metadata:
      labels:
        app: k8s-integration-demo
    spec:
      containers:
      - name: app
        image: k8s-integration-demo:latest
        ports:
        - containerPort: 3000
```

**k8s-service.yml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: k8s-integration-demo-service
spec:
  selector:
    app: k8s-integration-demo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

#### Steps to Deploy to Kubernetes
1. Build and push the Docker image (replace `your-dockerhub-username` with your Docker Hub username):
   ```bash
   docker build -t your-dockerhub-username/k8s-integration-demo:latest .
   docker push your-dockerhub-username/k8s-integration-demo:latest
   ```
2. Ensure you have a Kubernetes cluster running (e.g., using Minikube or a cloud provider like GKE, EKS, or AKS).
   - Start Minikube (if using locally):
     ```bash
     minikube start
     ```
3. Apply the deployment and service:
   ```bash
   kubectl apply -f k8s-deployment.yml
   kubectl apply -f k8s-service.yml
   ```
   Output:
   ```
   deployment.apps/k8s-integration-demo created
   service/k8s-integration-demo-service created
   ```
4. Verify the deployment:
   ```bash
   kubectl get deployments
   ```
   Output:
   ```
   NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
   k8s-integration-demo   3/3     3            3           1m
   ```
5. Verify the service:
   ```bash
   kubectl get services
   ```
   Output:
   ```
   NAME                        TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
   k8s-integration-demo-service   LoadBalancer   10.96.123.45   <pending>     80:31234/TCP   1m
   ```
   - If using Minikube, get the service URL:
     ```bash
     minikube service k8s-integration-demo-service --url
     ```
     Example Output:
     ```
     http://192.168.49.2:31234
     ```
6. Access the app at the service URL (e.g., `http://192.168.49.2:31234`). You should see:
   ```
   Hello from the Kubernetes Integration Demo!
   ```

### 2. Docker and Helm Charts
Helm is a package manager for Kubernetes that simplifies deployment using charts (pre-configured templates). A Helm chart packages Kubernetes manifests and allows customization via values.

#### Example: Creating a Helm Chart for the Node.js App
We’ll create a Helm chart to deploy the Node.js app.

##### Helm Chart Files
**helm/Chart.yaml**
```yaml
apiVersion: v2
name: k8s-integration-demo
description: A Helm chart for deploying a Node.js app
version: 0.1.0
appVersion: "1.0"
```

**helm/values.yaml**
```yaml
replicaCount: 3

image:
  repository: your-dockerhub-username/k8s-integration-demo
  tag: latest

service:
  type: LoadBalancer
  port: 80
```

**helm/templates/deployment.yaml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-app
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
      - name: app
        image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
        ports:
        - containerPort: 3000
```

**helm/templates/service.yaml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
spec:
  selector:
    app: {{ .Release.Name }}
  ports:
    - protocol: TCP
      port: {{ .Values.service.port }}
      targetPort: 3000
  type: {{ .Values.service.type }}
```

#### Steps to Deploy with Helm
1. Ensure Helm is installed:
   ```bash
   curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```
2. Install the Helm chart:
   ```bash
   helm install k8s-demo ./helm
   ```
   Output:
   ```
   NAME: k8s-demo
   LAST DEPLOYED: Mon May 19 08:27:00 2025
   NAMESPACE: default
   STATUS: deployed
   REVISION: 1
   ```
3. Verify the deployment:
   ```bash
   kubectl get deployments
   ```
   Output:
   ```
   NAME              READY   UP-TO-DATE   AVAILABLE   AGE
   k8s-demo-app      3/3     3            3           1m
   ```
4. Verify the service:
   ```bash
   kubectl get services
   ```
   Output:
   ```
   NAME              TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
   k8s-demo-service  LoadBalancer   10.96.123.46   <pending>     80:31235/TCP   1m
   ```
5. Access the app using the service URL (same as above).
6. To uninstall the chart:
   ```bash
   helm uninstall k8s-demo
   ```

### 3. Kubernetes Pods and Services
Pods are the smallest deployable units in Kubernetes, running one or more containers. Services provide network access to pods, enabling load balancing and service discovery.

#### Using the Example Above
- **Pods:** The `k8s-deployment.yml` creates a deployment with 3 replicas, so Kubernetes schedules 3 pods:
  ```bash
  kubectl get pods
  ```
  Output:
  ```
  NAME                                    READY   STATUS    RESTARTS   AGE
  k8s-integration-demo-7b9d5c1a-abc12    1/1     Running   0          2m
  k8s-integration-demo-7b9d5c1a-def34    1/1     Running   0          2m
  k8s-integration-demo-7b9d5c1a-ghi56    1/1     Running   0          2m
  ```
  - Each pod runs a single container with the `k8s-integration-demo:latest` image.
- **Services:** The `k8s-service.yml` creates a `LoadBalancer` service that routes traffic to the pods:
  - The service targets pods with the label `app: k8s-integration-demo`.
  - It exposes port 80 externally, mapping to port 3000 on the pods.
  - Kubernetes load balances traffic across the 3 pods.

#### Test Load Balancing
1. Make multiple requests to the service URL:
   ```bash
   for i in {1..5}; do curl http://192.168.49.2:31234; done
   ```
   - Kubernetes distributes requests across the 3 pods.

### 4. CI/CD with Docker and Kubernetes
Automating deployment with CI/CD ensures consistent and reliable updates to your Kubernetes cluster. We’ll use GitHub Actions to build a Docker image, push it to Docker Hub, and deploy to Kubernetes.

#### Example: GitHub Actions Workflow
**deploy-k8s.yml**
```yaml
name: Deploy to Kubernetes

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

      # Log in to Docker Hub
      - name: Log in to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Build and push Docker image
      - name: Build and push Docker image
        run: |
          docker build -t ${{ secrets.DOCKERHUB_USERNAME }}/k8s-integration-demo:latest .
          docker push ${{ secrets.DOCKERHUB_USERNAME }}/k8s-integration-demo:latest

      # Set up kubectl
      - name: Set up kubectl
        uses: azure/setup-kubectl@v3
        with:
          version: 'latest'

      # Configure kubeconfig
      - name: Configure kubeconfig
        run: |
          mkdir -p $HOME/.kube
          echo "${{ secrets.KUBE_CONFIG }}" > $HOME/.kube/config

      # Deploy to Kubernetes
      - name: Deploy to Kubernetes
        run: |
          kubectl apply -f k8s-deployment.yml
          kubectl apply -f k8s-service.yml
          kubectl rollout restart deployment/k8s-integration-demo
```

#### Steps to Set Up CI/CD
1. Set up GitHub Secrets:
   - `DOCKERHUB_USERNAME`: Your Docker Hub username.
   - `DOCKERHUB_TOKEN`: Your Docker Hub access token.
   - `KUBE_CONFIG`: Your Kubernetes cluster’s kubeconfig file (base64 encoded).
2. Place `deploy-k8s.yml` in `.github/workflows/` in your repository.
3. Push to the `main` branch to trigger the workflow.
4. The workflow will:
   - Build and push the Docker image to Docker Hub.
   - Apply the Kubernetes manifests.
   - Restart the deployment to pull the updated image.

#### Verify the Deployment
1. Check the deployment status:
   ```bash
   kubectl get deployments
   ```
   Output:
   ```
   NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
   k8s-integration-demo   3/3     3            3           5m
   ```
2. Access the app at the service URL to confirm the update.

## 🚀 Getting Started

To integrate Docker with Kubernetes:
1. Add `app.js`, `package.json`, `Dockerfile`, `k8s-deployment.yml`, `k8s-service.yml`, `helm/`, and `deploy-k8s.yml` to your project.
2. Deploy the app manually using `kubectl apply` and access it via the service URL.
3. Use Helm to deploy the app with the provided chart and verify the deployment.
4. Explore pods and services with `kubectl get pods` and `kubectl get services`.
5. Set up the CI/CD pipeline with GitHub Actions and trigger a deployment by pushing to `main`.
6. Clean up by deleting the deployment and service:
   ```bash
   kubectl delete -f k8s-deployment.yml
   kubectl delete -f k8s-service.yml
   ```

Kubernetes integration with Docker enables scalable and automated deployments. Move on to the next sections of the roadmap to explore advanced Kubernetes concepts, monitoring, and more!