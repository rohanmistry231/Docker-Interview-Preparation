# 🖥️ Docker Commands

This section covers essential Docker commands to manage containers, images, volumes, and networks. You'll learn how to build, run, and push Docker images, monitor containers with commands like `docker ps` and `docker logs`, manage images and containers, and work with Docker volumes and networking. Let’s get started with hands-on examples!

## 🏗️ Sub-Topics

### 1. `docker build`, `docker run`, `docker push`
These commands are the foundation of working with Docker images and containers.

#### Hands-On Example: Building, Running, and Pushing a Node.js App
We’ll use a simple Node.js app to demonstrate these commands.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the Docker Commands Demo!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "docker-commands-demo",
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

#### Commands Explained
- **`docker build`:**
  Builds a Docker image from a Dockerfile.
  ```bash
  docker build -t docker-commands-demo:latest .
  ```
  - `-t docker-commands-demo:latest` tags the image with the name `docker-commands-demo` and tag `latest`.
  - `.` specifies the build context (current directory).

- **`docker run`:**
  Runs a container from an image.
  ```bash
  docker run -d -p 3000:3000 --name demo-container docker-commands-demo:latest
  ```
  - `-d` runs the container in detached mode (in the background).
  - `-p 3000:3000` maps port 3000 on the host to port 3000 in the container.
  - `--name demo-container` names the container.
  - `docker-commands-demo:latest` specifies the image to run.

  After running, you can access the app at `http://localhost:3000`.

- **`docker push`:**
  Pushes an image to a registry (e.g., Docker Hub).
  ```bash
  # Log in to Docker Hub
  docker login -u YOUR_USERNAME -p YOUR_PASSWORD

  # Tag the image for Docker Hub
  docker tag docker-commands-demo:latest YOUR_USERNAME/docker-commands-demo:latest

  # Push the image
  docker push YOUR_USERNAME/docker-commands-demo:latest
  ```
  - Replace `YOUR_USERNAME` and `YOUR_PASSWORD` with your Docker Hub credentials.
  - The image will be available on Docker Hub after pushing.

### 2. `docker ps`, `docker logs`, `docker exec`
These commands help you monitor and interact with running containers.

#### Using the Container from the Previous Example
Let’s assume the container `demo-container` is running (from the `docker run` command above).

- **`docker ps`:**
  Lists running containers.
  ```bash
  docker ps
  ```
  Output:
  ```
  CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                    NAMES
  abc123def456   docker-commands-demo:latest   "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes   0.0.0.0:3000->3000/tcp   demo-container
  ```
  - Use `docker ps -a` to see all containers, including stopped ones.

- **`docker logs`:**
  Displays the logs of a container.
  ```bash
  docker logs demo-container
  ```
  Output:
  ```
  Server running on port 3000
  ```
  - Useful for debugging and monitoring application output.

- **`docker exec`:**
  Runs a command inside a running container.
  ```bash
  docker exec -it demo-container /bin/bash
  ```
  - `-it` makes the session interactive with a terminal.
  - `/bin/bash` starts a bash shell inside the container.
  - Once inside, you can run commands like `ls`, `node --version`, or `cat package.json`.

  Example command inside the container:
  ```bash
  node --version
  ```
  Output:
  ```
  v18.20.4
  ```

  Exit the container shell with `exit`.

### 3. Managing Images and Containers
Managing images and containers involves inspecting, stopping, removing, and pruning unused resources.

#### Commands for Images
- **List Images:**
  ```bash
  docker images
  ```
  Output:
  ```
  REPOSITORY              TAG       IMAGE ID       CREATED         SIZE
  docker-commands-demo    latest    789abc123def   5 minutes ago   950MB
  node                    18        456def789abc   1 week ago      910MB
  ```

- **Inspect an Image:**
  ```bash
  docker image inspect docker-commands-demo:latest
  ```
  - Displays detailed metadata about the image (e.g., layers, environment variables).

- **Remove an Image:**
  ```bash
  docker rmi docker-commands-demo:latest
  ```
  - Removes the image if no containers are using it. Use `-f` to force removal.

- **Prune Unused Images:**
  ```bash
  docker image prune
  ```
  - Removes dangling images (not tagged and not used by any container).

#### Commands for Containers
- **Stop a Container:**
  ```bash
  docker stop demo-container
  ```
  - Gracefully stops the running container.

- **Remove a Container:**
  ```bash
  docker rm demo-container
  ```
  - Removes the container after stopping it. Use `-f` to force removal of a running container.

- **Inspect a Container:**
  ```bash
  docker inspect demo-container
  ```
  - Displays detailed metadata about the container (e.g., network settings, volumes).

- **Prune Unused Containers:**
  ```bash
  docker container prune
  ```
  - Removes all stopped containers.

### 4. Docker Volumes and Networking
Docker volumes and networking enable persistent storage and communication between containers.

#### Hands-On Example: Using Volumes and Networking with Docker Compose
We’ll use Docker Compose to define a multi-container app with volumes and networking.

##### Supporting File
**docker-compose.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - app-data:/app/data
    networks:
      - demo-network
    environment:
      - NODE_ENV=production

  redis:
    image: redis:6.2
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - demo-network

volumes:
  app-data:
  redis-data:

networks:
  demo-network:
    driver: bridge
```

#### Volumes Explained
- **Volumes in Docker:**
  Volumes provide persistent storage for containers, ensuring data persists even if the container is removed.
  - In the `docker-compose.yml`, `app-data` and `redis-data` are named volumes.
  - `app-data:/app/data` mounts the `app-data` volume to `/app/data` in the `app` container.
  - `redis-data:/data` mounts the `redis-data` volume to `/data` in the `redis` container.

- **Commands for Volumes:**
  - List volumes:
    ```bash
    docker volume ls
    ```
    Output:
    ```
    DRIVER    VOLUME NAME
    local     docker-commands-demo_app-data
    local     docker-commands-demo_redis-data
    ```

  - Inspect a volume:
    ```bash
    docker volume inspect docker-commands-demo_app-data
    ```

  - Remove a volume:
    ```bash
    docker volume rm docker-commands-demo_app-data
    ```

  - Prune unused volumes:
    ```bash
    docker volume prune
    ```

#### Networking Explained
- **Networks in Docker:**
  Docker networks enable communication between containers.
  - In the `docker-compose.yml`, `demo-network` is a custom bridge network.
  - Both `app` and `redis` services are attached to `demo-network`, allowing them to communicate using their service names (`app` and `redis`) as hostnames.
  - The `bridge` driver is the default network type, isolating containers on the same host.

- **Commands for Networks:**
  - List networks:
    ```bash
    docker network ls
    ```
    Output:
    ```
    NETWORK ID     NAME                    DRIVER    SCOPE
    123abc456def   bridge                  bridge    local
    789def123abc   docker-commands-demo_demo-network   bridge    local
    ```

  - Inspect a network:
    ```bash
    docker network inspect docker-commands-demo_demo-network
    ```

  - Create a network:
    ```bash
    docker network create my-network
    ```

  - Remove a network:
    ```bash
    docker network rm my-network
    ```

#### Steps to Run the Docker Compose Example
1. Ensure `app.js`, `package.json`, `Dockerfile`, and `docker-compose.yml` are in your repository.
2. Start the services:
   ```bash
   docker-compose up -d
   ```
   - `-d` runs the services in detached mode.

3. Verify the services are running:
   ```bash
   docker-compose ps
   ```
   Output:
   ```
   Name                     Command               State           Ports
   --------------------------------------------------------------------------------
   app_1     docker-entrypoint.sh node app.js   Up      0.0.0.0:3000->3000/tcp
   redis_1   docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
   ```

4. Test the app at `http://localhost:3000`.

5. Test container communication (e.g., ping Redis from the app container):
   ```bash
   docker exec -it docker-commands-demo-app-1 ping redis -c 4
   ```

6. Stop and remove the services:
   ```bash
   docker-compose down -v
   ```
   - `-v` removes the volumes.

## 🚀 Getting Started

To master these Docker commands:
1. Follow the example for `docker build`, `docker run`, and `docker push` to build, run, and push a Docker image.
2. Use `docker ps`, `docker logs`, and `docker exec` to monitor and interact with your container.
3. Practice managing images and containers with the provided commands.
4. Set up the Docker Compose example to explore volumes and networking.
4. Experiment with additional Docker commands to deepen your understanding.

These commands are essential for working with Docker in CI/CD pipelines and production environments. Move on to the next sections of the roadmap to explore Docker Compose, CI/CD integration, and more!