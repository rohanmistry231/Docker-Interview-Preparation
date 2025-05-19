# 📜 Docker Basics

This section covers the foundational concepts of Docker, providing a solid understanding of its core components and functionality. You'll learn the difference between containers and virtual machines, explore Docker's architecture, install Docker on your system, and get hands-on experience with Docker images and containers. Let’s dive in!

## 🏗️ Sub-Topics

### 1. Containers vs. VMs
Containers and virtual machines (VMs) are both used for virtualization, but they differ significantly in their approach and resource usage.

- **Virtual Machines (VMs):**
  - VMs emulate an entire operating system, including the kernel, on top of a hypervisor (e.g., VMware, VirtualBox).
  - Each VM includes a full OS, libraries, and the application, making them heavy (several GBs in size).
  - VMs are isolated at the hardware level, which provides strong security but consumes more resources.
  - Use case: Running multiple OS environments on the same hardware.

- **Containers:**
  - Containers share the host OS kernel and use OS-level virtualization.
  - They include only the application and its dependencies (libraries, binaries), making them lightweight (MBs in size).
  - Containers are isolated at the process level using namespaces and cgroups, which is less resource-intensive.
  - Use case: Deploying applications consistently across development, testing, and production.

**Key Differences:**
| Feature            | Containers              | Virtual Machines       |
|--------------------|-------------------------|------------------------|
| Size               | Lightweight (MBs)       | Heavy (GBs)            |
| Boot Time          | Seconds                 | Minutes                |
| Resource Usage     | Low (shared kernel)     | High (full OS)         |
| Isolation          | Process-level           | Hardware-level         |
| Portability        | High (runs anywhere)    | Moderate (hypervisor)  |

**Diagram:**
```
[Virtual Machine]           [Container]
+----------------+         +----------------+
| App + Libs     |         | App + Libs     |
| Guest OS       |         |                |
| Hypervisor     |         +----------------+
| Host OS        |         | Host OS        |
| Hardware       |         | Hardware       |
+----------------+         +----------------+
```

### 2. Docker Architecture (Engine, Daemon, CLI)
Docker's architecture consists of several components that work together to manage containers.

- **Docker Engine:**
  - The core runtime that manages the lifecycle of containers.
  - It includes the Docker Daemon, APIs, and CLI.
  - Runs on the host OS and enables container creation, execution, and management.

- **Docker Daemon (`dockerd`):**
  - A background service running on the host OS.
  - Listens for Docker API requests and manages Docker objects (images, containers, networks, volumes).
  - Communicates with the kernel to create and manage containers using namespaces and cgroups.

- **Docker CLI (`docker`):**
  - The command-line interface used to interact with the Docker Daemon.
  - Commands like `docker run`, `docker build`, and `docker ps` are executed via the CLI.
  - Communicates with the Daemon via REST API (usually over a UNIX socket).

- **Other Components:**
  - **Docker Registry:** Stores Docker images (e.g., Docker Hub, AWS ECR).
  - **Docker Images:** Read-only templates used to create containers.
  - **Containers:** Runnable instances of images.

**Architecture Diagram:**
```
[User]
  |
[Docker CLI] --- (REST API) ---> [Docker Daemon]
  |                                 |
  |                                 v
  |                            [Docker Engine]
  |                                 |
  |                                 v
  |                            [Host OS Kernel]
  |                                 |
  |                                 v
  |                            [Containers]
  v
[Docker Registry]
```

### 3. Installing Docker
Docker can be installed on various operating systems. Below is an example of installing Docker on Ubuntu, a common environment for DevOps.

#### Installation Script for Ubuntu
```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker and enable it on boot
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
```

#### Steps to Use:
1. Copy the script into a file named `install-docker.sh`.
2. Run the script with `sudo bash install-docker.sh`.
3. After installation, test Docker by running `docker run hello-world`.

**Note:** For other OSes (e.g., macOS, Windows), refer to the official Docker documentation: https://docs.docker.com/get-docker/.

### 4. Docker Images and Containers
Docker images are read-only templates used to create containers, which are runnable instances of images.

#### Hands-On Example: Building and Running a Node.js App
Let’s build a Docker image for a simple Node.js app and run it as a container.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the Docker Demo!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "docker-demo",
    "version": "1.0.0",
    "main": "app.js",
    "dependencies": {
        "express": "^4.18.2"
    }
}
```

**Dockerfile**
```dockerfile
# Dockerfile for a simple Node.js app
FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
```

#### Steps to Build and Run:
1. **Build the Docker Image:**
   ```bash
   docker build -t docker-demo:latest .
   ```
   - `-t docker-demo:latest` tags the image as `docker-demo` with the `latest` tag.
   - `.` specifies the build context (current directory).

2. **Run the Container:**
   ```bash
   docker run -d -p 3000:3000 --name docker-demo-container docker-demo:latest
   ```
   - `-d` runs the container in detached mode.
   - `-p 3000:3000` maps port 3000 on the host to port 3000 in the container.
   - `--name docker-demo-container` names the container.

3. **Verify the Container is Running:**
   ```bash
   docker ps
   ```
   You should see `docker-demo-container` in the list of running containers.

4. **Access the App:**
   Open a browser and navigate to `http://localhost:3000`. You should see "Hello from the Docker Demo!".

5. **View Container Logs:**
   ```bash
   docker logs docker-demo-container
   ```

6. **Stop and Remove the Container:**
   ```bash
   docker stop docker-demo-container
   docker rm docker-demo-container
   ```

#### Key Commands for Images and Containers:
- List images: `docker images`
- Remove an image: `docker rmi docker-demo:latest`
- List all containers (including stopped): `docker ps -a`
- Remove a container: `docker rm docker-demo-container`

## 🚀 Getting Started

To explore these concepts:
1. Review the explanations for Containers vs. VMs and Docker Architecture to build a conceptual foundation.
2. Install Docker on your system using the provided script or official documentation.
3. Follow the hands-on example for Docker Images and Containers to build and run your first container.
4. Experiment with Docker commands to manage images and containers.

These foundational concepts will prepare you for more advanced Docker topics like networking, Docker Compose, and CI/CD integration. Move on to the next sections of the roadmap to continue your Docker journey!