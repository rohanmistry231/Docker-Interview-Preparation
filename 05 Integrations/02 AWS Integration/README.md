# ☁️ AWS Integration

This section explores how to integrate Docker with AWS services for containerized applications. You’ll learn how to run Docker containers on AWS ECS and EKS, store images in AWS ECR, and use Docker containers with AWS Lambda. These techniques are essential for deploying scalable applications on AWS. Let’s dive in with a practical example using a Node.js app!

## 🏗️ Sub-Topics

### 1. Docker on AWS ECS
Amazon Elastic Container Service (ECS) is a managed container orchestration service that runs Docker containers on AWS. You define a task definition, create a cluster, and deploy services.

#### Hands-On Example: Deploying a Node.js App to ECS
We’ll deploy a Node.js app to ECS using a task definition and service.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the AWS Integration Demo on ECS!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "aws-integration-demo",
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

**ecs-task-definition.json**
```json
{
    "family": "aws-integration-demo-task",
    "networkMode": "awsvpc",
    "containerDefinitions": [
        {
            "name": "app",
            "image": "<your-ecr-repo-uri>:latest",
            "portMappings": [
                {
                    "containerPort": 3000,
                    "hostPort": 3000,
                    "protocol": "tcp"
                }
            ],
            "essential": true,
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/aws-integration-demo",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
            }
        }
    ],
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "256",
    "memory": "512"
}
```

#### Steps to Deploy to ECS
1. Ensure you have the AWS CLI installed and configured:
   ```bash
   aws configure
   ```
2. Build and push the Docker image to ECR (see the "Storing Images in AWS ECR" section below for details).
3. Create a log group in CloudWatch:
   ```bash
   aws logs create-log-group --log-group-name /ecs/aws-integration-demo --region us-east-1
   ```
4. Register the task definition (replace `<your-ecr-repo-uri>` with your ECR URI):
   ```bash
   aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json --region us-east-1
   ```
   Output:
   ```
   {
       "taskDefinition": {
           "family": "aws-integration-demo-task",
           ...
       }
   }
   ```
5. Create an ECS cluster:
   ```bash
   aws ecs create-cluster --cluster-name aws-integration-demo-cluster --region us-east-1
   ```
6. Create a service to run the task (you’ll need a VPC, subnets, and security group configured; replace with your values):
   ```bash
   aws ecs create-service \
       --cluster aws-integration-demo-cluster \
       --service-name aws-integration-demo-service \
       --task-definition aws-integration-demo-task \
       --desired-count 1 \
       --launch-type FARGATE \
       --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678],securityGroups=[sg-12345678],assignPublicIp=ENABLED}" \
       --region us-east-1
   ```
7. Get the public IP of the task:
   ```bash
   aws ecs list-tasks --cluster aws-integration-demo-cluster --region us-east-1
   aws ecs describe-tasks --cluster aws-integration-demo-cluster --tasks <task-arn> --region us-east-1
   ```
   - Find the ENI and get the public IP from the network interface.
8. Access the app at `http://<public-ip>:3000`. You should see:
   ```
   Hello from the AWS Integration Demo on ECS!
   ```

### 2. Docker on AWS EKS
Amazon Elastic Kubernetes Service (EKS) is a managed Kubernetes service that integrates with Docker for container orchestration. You can deploy Docker containers to EKS using Kubernetes manifests.

#### Example: Deploying the Node.js App to EKS
We’ll reuse the Node.js app and deploy it to EKS using Kubernetes manifests.

##### Supporting Files
**k8s-deployment.yml**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aws-integration-demo
  labels:
    app: aws-integration-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: aws-integration-demo
  template:
    metadata:
      labels:
        app: aws-integration-demo
    spec:
      containers:
      - name: app
        image: <your-ecr-repo-uri>:latest
        ports:
        - containerPort: 3000
```

**k8s-service.yml**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: aws-integration-demo-service
spec:
  selector:
    app: aws-integration-demo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

#### Steps to Deploy to EKS
1. Create an EKS cluster (using `eksctl` for simplicity):
   ```bash
   eksctl create cluster --name aws-integration-demo-cluster --region us-east-1 --nodegroup-name standard-workers --node-type t3.medium --nodes 2
   ```
   - This takes ~15 minutes.
2. Configure `kubectl` to use the EKS cluster:
   ```bash
   aws eks update-kubeconfig --name aws-integration-demo-cluster --region us-east-1
   ```
3. Apply the deployment and service (replace `<your-ecr-repo-uri>` with your ECR URI):
   ```bash
   kubectl apply -f k8s-deployment.yml
   kubectl apply -f k8s-service.yml
   ```
   Output:
   ```
   deployment.apps/aws-integration-demo created
   service/aws-integration-demo-service created
   ```
4. Verify the deployment:
   ```bash
   kubectl get deployments
   ```
   Output:
   ```
   NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
   aws-integration-demo   3/3     3            3           1m
   ```
5. Get the service URL:
   ```bash
   kubectl get services
   ```
   Output:
   ```
   NAME                        TYPE           CLUSTER-IP     EXTERNAL-IP                              PORT(S)        AGE
   aws-integration-demo-service   LoadBalancer   10.100.123.45   a1234567890abcdef.elb.us-east-1.amazonaws.com   80:31234/TCP   1m
   ```
6. Access the app at the `EXTERNAL-IP` (e.g., `http://a1234567890abcdef.elb.us-east-1.amazonaws.com`). You should see:
   ```
   Hello from the AWS Integration Demo on ECS!
   ```

### 3. Storing Images in AWS ECR
Amazon Elastic Container Registry (ECR) is a managed Docker container registry for storing, managing, and deploying Docker images.

#### Example: Pushing the Node.js App Image to ECR
We’ll create a script to push the Docker image to ECR.

##### Supporting Files
**push-to-ecr.sh**
```bash
#!/bin/bash

# Variables
AWS_REGION="us-east-1"
REPO_NAME="aws-integration-demo"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Create ECR repository
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION

# Log in to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build Docker image
docker build -t $REPO_NAME:latest .

# Tag the image
docker tag $REPO_NAME:latest $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest

# Push the image to ECR
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest

# Output the ECR URI
echo "ECR URI: $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:latest"
```

#### Steps to Push to ECR
1. Ensure the AWS CLI is configured.
2. Make the script executable:
   ```bash
   chmod +x push-to-ecr.sh
   ```
3. Run the script:
   ```bash
   ./push-to-ecr.sh
   ```
   Example Output:
   ```
   {
       "repository": {
           "repositoryUri": "123456789012.dkr.ecr.us-east-1.amazonaws.com/aws-integration-demo"
       }
   }
   ...
   ECR URI: 123456789012.dkr.ecr.us-east-1.amazonaws.com/aws-integration-demo:latest
   ```
   - Use this URI in the ECS task definition and EKS deployment.

### 4. Lambda with Docker Containers
AWS Lambda supports running functions in Docker containers, allowing you to package dependencies and runtimes easily.

#### Example: Creating a Lambda Function with Docker
We’ll create a Lambda-compatible Dockerfile for a Node.js function.

##### Supporting Files
**Dockerfile.lambda**
```dockerfile
# Dockerfile for AWS Lambda
FROM public.ecr.aws/lambda/nodejs:18

# Copy function code
COPY app.js ${LAMBDA_TASK_ROOT}

# Set the CMD to the Lambda handler
CMD ["app.handler"]
```

#### Update `app.js` for Lambda
Modify `app.js` to work as a Lambda function (this will overwrite the previous `app.js` for Lambda-specific usage):

<xaiArtifact artifact_id="ae550a38-baac-442b-b595-0a18b70cf846" artifact_version_id="ea4f768b-5ee5-443a-a428-c1d54f0761af" title="app.js" contentType="text/javascript">
exports.handler = async (event) => {
    return {
        statusCode: 200,
        body: JSON.stringify('Hello from the AWS Lambda Docker Demo!')
    };
};