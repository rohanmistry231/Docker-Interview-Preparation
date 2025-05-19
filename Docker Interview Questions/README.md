# Docker Interview Questions for AI/ML Roles

This README provides **170 Docker interview questions** tailored for AI/ML students preparing for technical interviews, focusing on using Docker to containerize machine learning workflows, including building, testing, and deploying ML models. The questions are categorized into **Docker Basics**, **Dockerfile Creation**, **Docker Compose**, **CI/CD with Docker**, **Docker for AI/ML**, **Networking & Storage**, **Security & Best Practices**, and **Advanced Docker Concepts**. Each category is divided into **Basic**, **Intermediate**, and **Advanced** levels, with practical code snippets using Dockerfiles, Docker Compose YAML, and shell commands for tasks like containerizing Python ML applications, managing multi-container pipelines, and securing containers. This resource supports candidates aiming for roles such as data scientists, ML engineers, or DevOps engineers working on containerized ML pipelines.

## Docker Basics

### Basic
1. **What is Docker, and how is it used in AI/ML?**  
   Docker is a platform for containerizing applications, isolating them with their dependencies. In AI/ML, it ensures consistent environments for model training and deployment.  
   ```bash
   docker run -it python:3.9 bash
   ```

2. **How do you install Docker on a system?**  
   Installs Docker using package managers (e.g., `apt` on Ubuntu).  
   ```bash
   sudo apt-get update
   sudo apt-get install -y docker.io
   ```

3. **What is a Docker container?**  
   A lightweight, isolated environment running an application and its dependencies.  
   ```bash
   docker run --name ml-container python:3.9 echo "ML Container"
   ```

4. **How do you list running Docker containers?**  
   Uses `docker ps`.  
   ```bash
   docker ps
   ```

5. **How do you stop and remove a container?**  
   Stops and removes a container by ID or name.  
   ```bash
   docker stop ml-container
   docker rm ml-container
   ```

6. **What is a Docker image?**  
   A read-only template for creating containers.  
   ```bash
   docker pull python:3.9
   ```

#### Intermediate
7. **How do you build a Docker image?**  
   Uses a Dockerfile to build an image.  
   ```dockerfile
   FROM python:3.9
   COPY . /app
   WORKDIR /app
   RUN pip install -r requirements.txt
   CMD ["python", "app.py"]
   ```
   ```bash
   docker build -t ml-app .
   ```

8. **How do you push a Docker image to a registry?**  
   Pushes to Docker Hub or another registry.  
   ```bash
   docker tag ml-app myuser/ml-app:latest
   docker push myuser/ml-app:latest
   ```

9. **How do you run a container in detached mode?**  
   Uses `-d` flag to run in the background.  
   ```bash
   docker run -d --name ml-app ml-app
   ```

10. **How do you view container logs?**  
   Uses `docker logs`.  
   ```bash
   docker logs ml-app
   ```

11. **How do you execute a command in a running container?**  
   Uses `docker exec`.  
   ```bash
   docker exec ml-app python --version
   ```

12. **How do you inspect a container’s details?**  
   Uses `docker inspect`.  
   ```bash
   docker inspect ml-app
   ```

#### Advanced
13. **How do you optimize Docker image size?**  
   Uses multi-stage builds to reduce image size.  
   ```dockerfile
   FROM python:3.9 AS builder
   COPY requirements.txt .
   RUN pip install --target=/install -r requirements.txt
   FROM python:3.9-slim
   COPY --from=builder /install /usr/local/lib/python3.9/site-packages
   COPY . /app
   WORKDIR /app
   CMD ["python", "app.py"]
   ```
   ```bash
   docker build -t ml-optimized .
   ```

14. **How do you manage Docker image layers?**  
   Combines commands to minimize layers.  
   ```dockerfile
   FROM python:3.9
   RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
   ```

15. **How do you handle container resource limits?**  
   Sets CPU and memory limits.  
   ```bash
   docker run --memory="512m" --cpus="1" ml-app
   ```

16. **How do you debug a Docker container?**  
   Uses `docker logs` and `docker exec` for troubleshooting.  
   ```bash
   docker logs ml-app
   docker exec -it ml-app bash
   ```

17. **How do you manage Docker image versions?**  
   Tags images with specific versions.  
   ```bash
   docker tag ml-app myuser/ml-app:1.0.0
   docker push myuser/ml-app:1.0.0
   ```

18. **How do you clean up unused Docker resources?**  
   Removes unused images and containers.  
   ```bash
   docker system prune -f
   ```

## Dockerfile Creation

### Basic
19. **How do you create a basic Dockerfile for an ML app?**  
   Defines a Python-based ML app.  
   ```dockerfile
   FROM python:3.9
   COPY . /app
   WORKDIR /app
   RUN pip install -r requirements.txt
   CMD ["python", "train.py"]
   ```

20. **What is the `FROM` instruction in a Dockerfile?**  
   Specifies the base image.  
   ```dockerfile
   FROM python:3.9
   ```

21. **How do you copy files into a Docker image?**  
   Uses `COPY` to add files.  
   ```dockerfile
   COPY requirements.txt /app/
   ```

22. **What is the `CMD` instruction?**  
   Defines the default command to run.  
   ```dockerfile
   CMD ["python", "app.py"]
   ```

23. **How do you set a working directory in a Dockerfile?**  
   Uses `WORKDIR`.  
   ```dockerfile
   WORKDIR /app
   ```

24. **How do you install dependencies in a Dockerfile?**  
   Uses `RUN` to execute commands.  
   ```dockerfile
   RUN pip install -r requirements.txt
   ```

#### Intermediate
25. **How do you create a Dockerfile for a multi-stage build?**  
   Separates build and runtime environments.  
   ```dockerfile
   FROM python:3.9 AS builder
   RUN pip install --target=/install numpy
   FROM python:3.9-slim
   COPY --from=builder /install /usr/local/lib/python3.9/site-packages
   CMD ["python", "-c", "import numpy"]
   ```

26. **How do you use environment variables in a Dockerfile?**  
   Sets variables with `ENV`.  
   ```dockerfile
   ENV MODEL_NAME=my-model
   CMD ["python", "app.py"]
   ```

27. **How do you expose ports in a Dockerfile?**  
   Uses `EXPOSE` to document ports.  
   ```dockerfile
   EXPOSE 5000
   CMD ["python", "server.py"]
   ```

28. **How do you add a health check to a Dockerfile?**  
   Uses `HEALTHCHECK` to monitor container health.  
   ```dockerfile
   HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1
   ```

29. **How do you create a Dockerfile for a GPU-enabled ML app?**  
   Uses NVIDIA base image.  
   ```dockerfile
   FROM nvidia/cuda:11.2-base
   RUN apt-get update && apt-get install -y python3
   CMD ["python3"]
   ```

30. **How do you handle Dockerfile caching?**  
   Orders commands to maximize cache usage.  
   ```dockerfile
   FROM python:3.9
   COPY requirements.txt .
   RUN pip install -r requirements.txt
   COPY . /app
   ```

#### Advanced
31. **How do you create a minimal Dockerfile for ML deployment?**  
   Uses `slim` base image and minimal dependencies.  
   ```dockerfile
   FROM python:3.9-slim
   COPY model.pkl /app/
   COPY server.py /app/
   RUN pip install flask
   CMD ["python", "/app/server.py"]
   ```

32. **How do you secure a Dockerfile?**  
   Avoids root user and minimizes dependencies.  
   ```dockerfile
   FROM python:3.9-slim
   RUN useradd -m appuser
   USER appuser
   COPY . /app
   CMD ["python", "/app/app.py"]
   ```

33. **How do you optimize Dockerfile build time?**  
   Combines commands and uses cache.  
   ```dockerfile
   FROM python:3.9
   RUN pip install numpy pandas && apt-get update && apt-get install -y curl
   ```

34. **How do you create a Dockerfile for multi-architecture support?**  
   Uses `buildx` for cross-platform builds.  
   ```bash
   docker buildx build --platform linux/amd64,linux/arm64 -t ml-app .
   ```

35. **How do you handle secrets in a Dockerfile?**  
   Uses build-time secrets (Docker 18.09+).  
   ```dockerfile
   # syntax=docker/dockerfile:1.2
   RUN --mount=type=secret,id=mysecret cat /run/secrets/mysecret
   ```

36. **How do you create a Dockerfile for model versioning?**  
   Tags images with model versions.  
   ```dockerfile
   FROM python:3.9
   ENV MODEL_VERSION=1.0.0
   CMD ["python", "-c", "print('$MODEL_VERSION')"]
   ```

## Docker Compose

### Basic
37. **What is Docker Compose, and how is it used in AI/ML?**  
   Manages multi-container applications, e.g., ML model and database.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: python:3.9
       command: python app.py
   ```

38. **How do you create a basic Docker Compose file?**  
   Defines a single service.  
   ```yaml
   version: '3.8'
   services:
     ml-app:
       build: .
       command: python train.py
   ```

39. **How do you run a Docker Compose application?**  
   Uses `docker-compose up`.  
   ```bash
   docker-compose up -d
   ```

40. **How do you stop a Docker Compose application?**  
   Uses `docker-compose down`.  
   ```bash
   docker-compose down
   ```

41. **How do you define environment variables in Docker Compose?**  
   Uses `environment` or `.env` file.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: python:3.9
       environment:
         - MODEL_NAME=my-model
   ```

42. **How do you map ports in Docker Compose?**  
   Uses `ports` to expose services.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: python:3.9
       ports:
         - "5000:5000"
   ```

#### Intermediate
43. **How do you create a multi-container ML pipeline with Docker Compose?**  
   Defines model and database services.  
   ```yaml
   version: '3.8'
   services:
     model:
       build: .
       command: python model.py
     db:
       image: postgres:13
       environment:
         - POSTGRES_DB=ml_db
   ```

44. **How do you use volumes in Docker Compose?**  
   Persists data across containers.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: python:3.9
       volumes:
         - ./data:/app/data
   ```

45. **How do you define dependencies in Docker Compose?**  
   Uses `depends_on`.  
   ```yaml
   version: '3.8'
   services:
     app:
       build: .
       depends_on:
         - db
     db:
       image: postgres:13
   ```

46. **How do you scale services in Docker Compose?**  
   Uses `--scale` flag.  
   ```bash
   docker-compose up --scale app=3
   ```

47. **How do you configure health checks in Docker Compose?**  
   Defines health check parameters.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: python:3.9
       healthcheck:
         test: ["CMD", "curl", "--fail", "http://localhost:5000/health"]
         interval: 30s
         timeout: 10s
   ```

48. **How do you use Docker Compose with GPU support?**  
   Configures NVIDIA runtime.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: nvidia/cuda:11.2-base
       deploy:
         resources:
           reservations:
             devices:
               - driver: nvidia
                 count: 1
                 capabilities: [gpu]
   ```

#### Advanced
49. **How do you optimize Docker Compose for ML pipelines?**  
   Uses caching and minimal services.  
   ```yaml
   version: '3.8'
   services:
     model:
       build:
         context: .
         cache_from:
           - ml-app:latest
       command: python train.py
   ```

50. **How do you create a Docker Compose file for model inference?**  
   Defines inference and API services.  
   ```yaml
   version: '3.8'
   services:
     inference:
       build: .
       command: python inference.py
     api:
       image: flask
       ports:
         - "5000:5000"
       depends_on:
         - inference
   ```

51. **How do you manage secrets in Docker Compose?**  
   Uses Docker secrets.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: python:3.9
       secrets:
         - my_secret
   secrets:
     my_secret:
       file: ./secret.txt
   ```

52. **How do you create a Docker Compose file for distributed ML training?**  
   Defines multiple training nodes.  
   ```yaml
   version: '3.8'
   services:
     trainer1:
       build: .
       command: python train.py --node 1
     trainer2:
       build: .
       command: python train.py --node 2
   ```

53. **How do you monitor Docker Compose services?**  
   Uses health checks and logs.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: python:3.9
       healthcheck:
         test: ["CMD", "python", "health.py"]
   ```

54. **How do you visualize Docker Compose performance?**  
   Tracks service resource usage.  
   ```bash
   docker-compose top
   ```

## CI/CD with Docker

### Basic
55. **How do you integrate Docker with CI/CD pipelines?**  
   Builds and pushes images in CI.  
   ```yaml
   name: Docker CI
   on: [push]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-build
   ```
   ```makefile
   docker-build:
   	docker build -t ml-app .
   ```

56. **How do you automate Docker image builds in CI?**  
   Uses GitHub Actions to build images.  
   ```yaml
   name: Build Docker
   on: [push]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-build
   ```
   ```makefile
   docker-build:
   	docker build -t ml-app .
   ```

57. **How do you test Docker images in CI?**  
   Runs container tests.  
   ```yaml
   name: Test Docker
   on: [push]
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-test
   ```
   ```makefile
   docker-test:
   	docker run ml-app python -m pytest
   ```

58. **How do you push Docker images to a registry in CI?**  
   Pushes to Docker Hub.  
   ```yaml
   name: Push Docker
   on: [push]
   jobs:
     push:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-push
           env:
             DOCKER_USER: ${{ secrets.DOCKER_USER }}
             DOCKER_PASS: ${{ secrets.DOCKER_PASS }}
   ```
   ```makefile
   docker-push:
   	echo "$(DOCKER_PASS)" | docker login -u $(DOCKER_USER) --password-stdin
   	docker push ml-app
   ```

59. **How do you cache Docker layers in CI?**  
   Uses `docker/build-push-action`.  
   ```yaml
   name: Cache Docker
   on: [push]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - uses: docker/build-push-action@v3
           with:
             cache-from: type=registry,ref=ml-app:cache
   ```

60. **How do you validate Docker images in CI?**  
   Runs image scans.  
   ```yaml
   name: Validate Docker
   on: [push]
   jobs:
     validate:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-validate
   ```
   ```makefile
   docker-validate:
   	docker scan ml-app
   ```

#### Intermediate
61. **How do you automate multi-stage Docker builds in CI?**  
   Uses multi-stage Dockerfile in CI.  
   ```yaml
   name: Multi-Stage Build
   on: [push]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-multi
   ```
   ```makefile
   docker-multi:
   	docker build -t ml-app -f Dockerfile.multi .
   ```

62. **How do you integrate Docker with GitHub Actions for ML?**  
   Builds and tests ML images.  
   ```yaml
   name: ML Docker CI
   on: [push]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-ml
   ```
   ```makefile
   docker-ml:
   	docker build -t ml-app .
   	docker run ml-app python -m pytest
   ```

63. **How do you handle large ML datasets in Docker CI?**  
   Mounts datasets as volumes.  
   ```yaml
   name: Large Dataset CI
   on: [push]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-data
   ```
   ```makefile
   docker-data:
   	docker run -v $(pwd)/data:/app/data ml-app python process.py
   ```

64. **How do you automate Docker image versioning in CI?**  
   Tags images with Git commit.  
   ```yaml
   name: Image Versioning
   on: [push]
   jobs:
     version:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-version
           env:
             COMMIT: ${{ github.sha }}
   ```
   ```makefile
   docker-version:
   	docker build -t ml-app:${COMMIT} .
   ```

65. **How do you optimize Docker CI pipelines?**  
   Caches layers and minimizes steps.  
   ```yaml
   name: Optimize Docker CI
   on: [push]
   jobs:
     optimize:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-fast
   ```
   ```makefile
   docker-fast:
   	docker build --cache-from ml-app:latest -t ml-app .
   ```

66. **How do you monitor Docker CI performance?**  
   Tracks build times.  
   ```yaml
   name: Docker CI Perf
   on: [push]
   jobs:
     perf:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-perf
   ```
   ```makefile
   docker-perf:
   	time docker build -t ml-app .
   ```

#### Advanced
67. **How do you create a multi-architecture Docker CI pipeline?**  
   Builds for multiple platforms.  
   ```yaml
   name: Multi-Arch CI
   on: [push]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-multi-arch
   ```
   ```makefile
   docker-multi-arch:
   	docker buildx build --platform linux/amd64,linux/arm64 -t ml-app .
   ```

68. **How do you automate Docker image security scans in CI?**  
   Uses Trivy for vulnerability scanning.  
   ```yaml
   name: Security Scan
   on: [push]
   jobs:
     scan:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-scan
   ```
   ```makefile
   docker-scan:
   	trivy image ml-app
   ```

69. **How do you create a Docker CI pipeline for GPU-enabled ML?**  
   Builds GPU-compatible images.  
   ```yaml
   name: GPU Docker CI
   on: [push]
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-gpu
   ```
   ```makefile
   docker-gpu:
   	docker build -t ml-gpu -f Dockerfile.gpu .
   ```

70. **How do you automate Docker image rollback in CI?**  
   Reverts to previous image on failure.  
   ```yaml
   name: Docker Rollback
   on: [push]
   jobs:
     rollback:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-rollback
   ```
   ```makefile
   docker-rollback:
   	docker tag ml-app:previous ml-app:latest
   ```

71. **How do you create a Docker CI pipeline for model registries?**  
   Pushes to private registries.  
   ```yaml
   name: Model Registry CI
   on: [push]
   jobs:
     registry:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-registry
           env:
             REGISTRY: ${{ secrets.REGISTRY }}
   ```
   ```makefile
   docker-registry:
   	docker push ${REGISTRY}/ml-app
   ```

72. **How do you visualize Docker CI performance metrics?**  
   Tracks build and test times.  
   ```yaml
   name: Docker CI Metrics
   on: [push]
   jobs:
     metrics:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-metrics
   ```
   ```makefile
   docker-metrics:
   	time docker build -t ml-app .
   	time docker run ml-app python -m pytest
   ```

## Docker for AI/ML

### Basic
73. **How do you containerize an ML model?**  
   Creates a Docker image for model inference.  
   ```dockerfile
   FROM python:3.9
   COPY model.pkl /app/
   COPY inference.py /app/
   RUN pip install scikit-learn
   CMD ["python", "/app/inference.py"]
   ```

74. **How do you run ML training in a Docker container?**  
   Executes training script in a container.  
   ```bash
   docker run -v $(pwd)/data:/app/data ml-app python train.py
   ```

75. **How do you serve an ML model with Docker?**  
   Runs a Flask API for inference.  
   ```dockerfile
   FROM python:3.9
   COPY . /app
   RUN pip install flask scikit-learn
   CMD ["python", "/app/server.py"]
   ```

76. **How do you manage ML dependencies in Docker?**  
   Uses `requirements.txt` in Dockerfile.  
   ```dockerfile
   FROM python:3.9
   COPY requirements.txt .
   RUN pip install -r requirements.txt
   ```

77. **How do you test ML models in Docker?**  
   Runs tests in a container.  
   ```bash
   docker run ml-app python -m pytest tests/
   ```

78. **How do you validate ML data in Docker?**  
   Runs data validation script.  
   ```bash
   docker run -v $(pwd)/data:/app/data ml-app python validate.py
   ```

#### Intermediate
79. **How do you containerize a GPU-based ML model?**  
   Uses NVIDIA Docker image.  
   ```dockerfile
   FROM nvidia/cuda:11.2-base
   RUN apt-get update && apt-get install -y python3-pip
   RUN pip3 install torch
   CMD ["python3", "train.py"]
   ```

80. **How do you manage large ML datasets in Docker?**  
   Uses volumes for data persistence.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: ml-app
       volumes:
         - ./data:/app/data
   ```

81. **How do you automate ML model versioning in Docker?**  
   Tags images with model versions.  
   ```bash
   docker build -t ml-app:1.0.0 .
   ```

82. **How do you optimize ML container performance?**  
   Limits resources and uses slim images.  
   ```bash
   docker run --memory="2g" --cpus="2" ml-app python train.py
   ```

83. **How do you integrate Docker with ML frameworks?**  
   Installs frameworks like TensorFlow.  
   ```dockerfile
   FROM python:3.9
   RUN pip install tensorflow
   CMD ["python", "train.py"]
   ```

84. **How do you monitor ML containers?**  
   Uses `docker stats`.  
   ```bash
   docker stats ml-app
   ```

#### Advanced
85. **How do you create a Docker image for distributed ML training?**  
   Configures for multi-node training.  
   ```dockerfile
   FROM python:3.9
   RUN pip install horovod
   CMD ["python", "distributed_train.py"]
   ```

86. **How do you containerize ML model pipelines?**  
   Defines pipeline stages in Compose.  
   ```yaml
   version: '3.8'
   services:
     preprocess:
       image: ml-app
       command: python preprocess.py
     train:
       image: ml-app
       command: python train.py
       depends_on:
         - preprocess
   ```

87. **How do you optimize Docker for large-scale ML?**  
   Uses multi-stage builds and caching.  
   ```dockerfile
   FROM python:3.9 AS builder
   RUN pip install --target=/install tensorflow
   FROM python:3.9-slim
   COPY --from=builder /install /usr/local/lib/python3.9/site-packages
   ```

88. **How do you create a Docker image for model explainability?**  
   Includes SHAP or LIME.  
   ```dockerfile
   FROM python:3.9
   RUN pip install shap
   CMD ["python", "explain.py"]
   ```

89. **How do you automate ML model deployment with Docker?**  
   Deploys to a registry and runs.  
   ```bash
   docker build -t ml-app .
   docker push myuser/ml-app
   docker run -p 5000:5000 myuser/ml-app
   ```

90. **How do you visualize ML container performance?**  
   Tracks resource usage.  
   ```bash
   docker stats --format "{{.Name}}: {{.CPUPerc}} {{.MemUsage}}"
   ```

## Networking & Storage

### Basic
91. **How do you configure Docker networking?**  
   Uses default bridge network.  
   ```bash
   docker run --name ml-app --network bridge ml-app
   ```

92. **How do you map ports in a Docker container?**  
   Uses `-p` to expose ports.  
   ```bash
   docker run -p 5000:5000 ml-app
   ```

93. **How do you create a Docker volume?**  
   Persists data outside containers.  
   ```bash
   docker volume create ml-data
   ```

94. **How do you mount a volume in a container?**  
   Uses `-v` to mount volumes.  
   ```bash
   docker run -v ml-data:/app/data ml-app
   ```

95. **How do you list Docker networks?**  
   Uses `docker network ls`.  
   ```bash
   docker network ls
   ```

96. **How do you inspect a Docker network?**  
   Uses `docker network inspect`.  
   ```bash
   docker network inspect bridge
   ```

#### Intermediate
97. **How do you create a custom Docker network?**  
   Defines a user-defined bridge network.  
   ```bash
   docker network create ml-network
   docker run --network ml-network ml-app
   ```

98. **How do you connect containers in Docker Compose?**  
   Uses a shared network.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: ml-app
     db:
       image: postgres:13
   networks:
     default:
       name: ml-network
   ```

99. **How do you manage persistent storage for ML data?**  
   Uses named volumes.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: ml-app
       volumes:
         - ml-data:/app/data
   volumes:
     ml-data:
   ```

100. **How do you configure host networking in Docker?**  
   Uses `--network host`.  
   ```bash
   docker run --network host ml-app
   ```

101. **How do you handle large ML datasets with Docker storage?**  
   Mounts external storage.  
   ```bash
   docker run -v /data:/app/data ml-app
   ```

102. **How do you optimize Docker networking for ML?**  
   Uses custom networks for low latency.  
   ```bash
   docker network create --driver bridge ml-fast
   ```

#### Advanced
103. **How do you create a Docker overlay network for ML clusters?**  
   Uses overlay for multi-host networking.  
   ```bash
   docker network create -d overlay ml-cluster
   ```

104. **How do you secure Docker networking?**  
   Uses encrypted networks.  
   ```bash
   docker network create -d overlay --opt encrypted ml-secure
   ```

105. **How do you manage storage for distributed ML training?**  
   Uses shared volumes across nodes.  
   ```yaml
   version: '3.8'
   services:
     trainer:
       image: ml-app
       volumes:
         - ml-shared:/app/data
   volumes:
     ml-shared:
   ```

106. **How do you optimize Docker storage for ML?**  
   Uses volume drivers for performance.  
   ```bash
   docker volume create --driver local ml-optimized
   ```

107. **How do you create a Docker network for model inference?**  
   Isolates inference services.  
   ```bash
   docker network create ml-inference
   docker run --network ml-inference ml-app
   ```

108. **How do you visualize Docker network performance?**  
   Monitors network traffic.  
   ```bash
   docker network inspect ml-network
   ```

## Security & Best Practices

### Basic
109. **How do you secure a Docker container?**  
   Runs as non-root user.  
   ```dockerfile
   FROM python:3.9
   RUN useradd -m appuser
   USER appuser
   CMD ["python", "app.py"]
   ```

110. **How do you manage Docker secrets?**  
   Uses Docker secrets in Compose.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: ml-app
       secrets:
         - api_key
   secrets:
     api_key:
       file: ./api_key.txt
   ```

111. **How do you limit container privileges?**  
   Uses `--cap-drop`.  
   ```bash
   docker run --cap-drop ALL ml-app
   ```

112. **How do you scan Docker images for vulnerabilities?**  
   Uses `docker scan`.  
   ```bash
   docker scan ml-app
   ```

113. **How do you update Docker images?**  
   Pulls latest base images.  
   ```bash
   docker pull python:3.9
   ```

114. **How do you enforce Docker best practices?**  
   Uses linters like Hadolint.  
   ```bash
   hadolint Dockerfile
   ```

#### Intermediate
115. **How do you secure Docker registries?**  
   Uses private registries with authentication.  
   ```bash
   docker login myregistry.com
   docker push myregistry.com/ml-app
   ```

116. **How do you manage container resource isolation?**  
   Uses cgroups for isolation.  
   ```bash
   docker run --memory="512m" --cpus="1" ml-app
   ```

117. **How do you automate Docker image signing?**  
   Uses Docker Content Trust.  
   ```bash
   export DOCKER_CONTENT_TRUST=1
   docker push myuser/ml-app
   ```

118. **How do you secure Docker Compose services?**  
   Restricts service permissions.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: ml-app
       user: appuser
   ```

119. **How do you monitor Docker security?**  
   Uses audit logs.  
   ```bash
   docker events
   ```

120. **How do you optimize Docker security?**  
   Minimizes attack surface.  
   ```dockerfile
   FROM python:3.9-slim
   RUN apt-get update && apt-get install -y --no-install-recommends curl
   ```

#### Advanced
121. **How do you create a secure Docker image for ML?**  
   Uses minimal base and non-root user.  
   ```dockerfile
   FROM python:3.9-slim
   RUN useradd -m mluser
   USER mluser
   COPY model.pkl /app/
   CMD ["python", "/app/inference.py"]
   ```

122. **How do you automate Docker security audits?**  
   Integrates Trivy in CI.  
   ```yaml
   name: Security Audit
   on: [push]
   jobs:
     audit:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: make docker-audit
   ```
   ```makefile
   docker-audit:
   	trivy image ml-app
   ```

123. **How do you enforce secure ML model deployment?**  
   Signs and encrypts models.  
   ```dockerfile
   FROM python:3.9
   RUN pip install cryptography
   CMD ["python", "secure_deploy.py"]
   ```

124. **How do you create a secure Docker network for ML?**  
   Uses encrypted overlay network.  
   ```bash
   docker network create -d overlay --opt encrypted ml-secure
   ```

125. **How do you manage secure ML data in Docker?**  
   Encrypts data volumes.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: ml-app
       volumes:
         - ml-encrypted:/app/data
   volumes:
     ml-encrypted:
   ```

126. **How do you visualize Docker security metrics?**  
   Tracks vulnerability scan results.  
   ```bash
   docker scan ml-app --json > security_metrics.json
   ```

## Advanced Docker Concepts

### Basic
127. **How do you use Docker for model orchestration?**  
   Runs multiple containers for pipeline.  
   ```yaml
   version: '3.8'
   services:
     preprocess:
       image: ml-app
       command: python preprocess.py
     train:
       image: ml-app
       command: python train.py
   ```

128. **How do you create a Docker image for model monitoring?**  
   Includes monitoring tools.  
   ```dockerfile
   FROM python:3.9
   RUN pip install prometheus-client
   CMD ["python", "monitor.py"]
   ```

129. **How do you use Docker for data preprocessing?**  
   Runs preprocessing in a container.  
   ```bash
   docker run -v $(pwd)/data:/app/data ml-app python preprocess.py
   ```

130. **How do you create a Docker image for model validation?**  
   Includes validation scripts.  
   ```dockerfile
   FROM python:3.9
   COPY validate.py /app/
   CMD ["python", "/app/validate.py"]
   ```

131. **How do you use Docker for model experimentation?**  
   Runs experiments in isolated containers.  
   ```bash
   docker run ml-app python experiment.py
   ```

132. **How do you visualize Docker resource usage?**  
   Uses `docker stats`.  
   ```bash
   docker stats --no-stream
   ```

#### Intermediate
133. **How do you create a Docker image for model fairness checks?**  
   Includes fairness libraries.  
   ```dockerfile
   FROM python:3.9
   RUN pip install aif360
   CMD ["python", "fairness.py"]
   ```

134. **How do you use Docker for model retraining?**  
   Triggers retraining in a container.  
   ```bash
   docker run -v $(pwd)/new_data:/app/data ml-app python retrain.py
   ```

135. **How do you create a Docker image for model benchmarking?**  
   Includes benchmarking tools.  
   ```dockerfile
   FROM python:3.9
   RUN pip install pytest-benchmark
   CMD ["python", "benchmark.py"]
   ```

136. **How do you use Docker for model performance tracking?**  
   Logs metrics in a container.  
   ```bash
   docker run ml-app python track_metrics.py
   ```

137. **How do you create a Docker image for model drift detection?**  
   Includes drift detection libraries.  
   ```dockerfile
   FROM python:3.9
   RUN pip install alibi-detect
   CMD ["python", "drift.py"]
   ```

138. **How do you optimize Docker for ML experimentation?**  
   Uses lightweight images and caching.  
   ```dockerfile
   FROM python:3.9-slim
   RUN pip install --no-cache-dir numpy
   ```

#### Advanced
139. **How do you create a Docker image for multi-model deployment?**  
   Supports multiple models in one image.  
   ```dockerfile
   FROM python:3.9
   COPY models/ /app/models
   CMD ["python", "multi_model.py"]
   ```

140. **How do you use Docker for model lifecycle management?**  
   Automates training, deployment, and retirement.  
   ```yaml
   version: '3.8'
   services:
     train:
       image: ml-app
       command: python train.py
     deploy:
       image: ml-app
       command: python deploy.py
   ```

141. **How do you create a Docker image for secure model inference?**  
   Encrypts inference outputs.  
   ```dockerfile
   FROM python:3.9
   RUN pip install cryptography
   CMD ["python", "secure_inference.py"]
   ```

142. **How do you use Docker for model A/B testing?**  
   Deploys multiple model versions.  
   ```yaml
   version: '3.8'
   services:
     model_a:
       image: ml-app:1.0
     model_b:
       image: ml-app:2.0
   ```

143. **How do you create a Docker image for model auditing?**  
   Includes audit logging.  
   ```dockerfile
   FROM python:3.9
   RUN pip install auditlog
   CMD ["python", "audit.py"]
   ```

144. **How do you optimize Docker for distributed ML?**  
   Uses overlay networks and optimized images.  
   ```bash
   docker network create -d overlay ml-distributed
   ```

145. **How do you create a Docker image for model compliance?**  
   Includes compliance checks.  
   ```dockerfile
   FROM python:3.9
   RUN pip install compliance
   CMD ["python", "compliance.py"]
   ```

146. **How do you use Docker for model rollback?**  
   Reverts to previous image.  
   ```bash
   docker tag ml-app:previous ml-app:latest
   docker run ml-app:latest
   ```

147. **How do you create a Docker image for model performance alerts?**  
   Includes alerting tools.  
   ```dockerfile
   FROM python:3.9
   RUN pip install slack-sdk
   CMD ["python", "alert.py"]
   ```

148. **How do you visualize ML pipeline performance in Docker?**  
   Tracks container metrics.  
   ```bash
   docker stats --format "{{.Name}}: {{.CPUPerc}} {{.MemUsage}}"
   ```

149. **How do you create a Docker image for model experimentation tracking?**  
   Includes tracking libraries.  
   ```dockerfile
   FROM python:3.9
   RUN pip install mlflow
   CMD ["python", "experiment.py"]
   ```

150. **How do you use Docker for secure model versioning?**  
   Signs versioned images.  
   ```bash
   export DOCKER_CONTENT_TRUST=1
   docker build -t ml-app:1.0.0 .
   ```

151. **How do you create a Docker image for model fairness auditing?**  
   Includes fairness audit tools.  
   ```dockerfile
   FROM python:3.9
   RUN pip install fairlearn
   CMD ["python", "fairness_audit.py"]
   ```

152. **How do you use Docker for model drift monitoring?**  
   Runs continuous drift checks.  
   ```bash
   docker run -v $(pwd)/data:/app/data ml-app python monitor_drift.py
   ```

153. **How do you create a Docker image for secure data preprocessing?**  
   Encrypts data during preprocessing.  
   ```dockerfile
   FROM python:3.9
   RUN pip install cryptography
   CMD ["python", "secure_preprocess.py"]
   ```

154. **How do you optimize Docker for ML model scalability?**  
   Uses orchestration tools like Docker Swarm.  
   ```bash
   docker swarm init
   docker service create --name ml-app ml-app
   ```

155. **How do you create a Docker image for model performance benchmarking?**  
   Includes benchmarking tools.  
   ```dockerfile
   FROM python:3.9
   RUN pip install locust
   CMD ["python", "benchmark.py"]
   ```

156. **How do you use Docker for model compliance reporting?**  
   Generates compliance reports.  
   ```bash
   docker run ml-app python compliance_report.py
   ```

157. **How do you create a Docker image for secure model retraining?**  
   Encrypts training data.  
   ```dockerfile
   FROM python:3.9
   RUN pip install cryptography
   CMD ["python", "secure_retrain.py"]
   ```

158. **How do you visualize Docker ML pipeline metrics?**  
   Tracks pipeline performance.  
   ```bash
   docker stats --format "{{.Name}}: {{.CPUPerc}} {{.MemUsage}}"
   ```

159. **How do you create a Docker image for model lifecycle auditing?**  
   Includes audit logging for lifecycle.  
   ```dockerfile
   FROM python:3.9
   RUN pip install auditlog
   CMD ["python", "lifecycle_audit.py"]
   ```

160. **How do you use Docker for secure model deployment pipelines?**  
   Secures deployment with signed images.  
   ```bash
   export DOCKER_CONTENT_TRUST=1
   docker run myuser/ml-app
   ```

161. **How do you create a Docker image for model performance monitoring?**  
   Includes monitoring libraries.  
   ```dockerfile
   FROM python:3.9
   RUN pip install prometheus-client
   CMD ["python", "monitor_performance.py"]
   ```

162. **How do you use Docker for model experimentation orchestration?**  
   Runs multiple experiment containers.  
   ```yaml
   version: '3.8'
   services:
     exp1:
       image: ml-app
       command: python experiment.py --config 1
     exp2:
       image: ml-app
       command: python experiment.py --config 2
   ```

163. **How do you create a Docker image for secure model validation?**  
   Encrypts validation data.  
   ```dockerfile
   FROM python:3.9
   RUN pip install cryptography
   CMD ["python", "secure_validate.py"]
   ```

164. **How do you optimize Docker for ML model fault tolerance?**  
   Uses health checks and restarts.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: ml-app
       restart: on-failure
       healthcheck:
         test: ["CMD", "python", "health.py"]
   ```

165. **How do you create a Docker image for model drift alerting?**  
   Includes alerting for drift detection.  
   ```dockerfile
   FROM python:3.9
   RUN pip install slack-sdk alibi-detect
   CMD ["python", "drift_alert.py"]
   ```

166. **How do you use Docker for model A/B testing orchestration?**  
   Deploys multiple model versions in parallel.  
   ```yaml
   version: '3.8'
   services:
     model_a:
       image: ml-app:1.0
       ports:
         - "5000:5000"
     model_b:
       image: ml-app:2.0
       ports:
         - "5001:5000"
   ```

167. **How do you create a Docker image for secure model auditing?**  
   Includes secure audit logging.  
   ```dockerfile
   FROM python:3.9
   RUN pip install auditlog cryptography
   CMD ["python", "secure_audit.py"]
   ```

168. **How do you visualize Docker ML experimentation metrics?**  
   Tracks experiment performance.  
   ```bash
   docker stats --format "{{.Name}}: {{.CPUPerc}} {{.MemUsage}}"
   ```

169. **How do you create a Docker image for model compliance auditing?**  
   Includes compliance audit tools.  
   ```dockerfile
   FROM python:3.9
   RUN pip install compliance-audit
   CMD ["python", "compliance_audit.py"]
   ```

170. **How do you use Docker for secure ML pipeline orchestration?**  
   Secures entire pipeline with encrypted networks and signed images.  
   ```yaml
   version: '3.8'
   services:
     app:
       image: ml-app
       networks:
         - ml-secure
   networks:
     ml-secure:
       driver: overlay
       driver_opts:
         encrypted: "true"
   ```