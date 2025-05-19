# 📜 Docker Compose

This section covers Docker Compose, a tool for defining and running multi-container Docker applications using YAML files. You’ll learn how to define multi-container apps, understand Docker Compose YAML syntax, manage services with `docker-compose` commands, and scale services for load balancing. Let’s explore these concepts with a practical example using a Node.js app and Redis!

## 🏗️ Sub-Topics

### 1. Defining Multi-Container Apps
Docker Compose allows you to define multiple containers, their configurations, and their relationships in a single YAML file. This is ideal for local development, testing, and small-scale deployments.

#### Hands-On Example: Node.js App with Redis
We’ll define a multi-container app with a Node.js web server and a Redis instance for caching.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the Docker Compose Demo!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "docker-compose-demo",
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

**docker-compose.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
    depends_on:
      - redis
    networks:
      - app-network

  redis:
    image: redis:6.2
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - app-network

volumes:
  redis-data:

networks:
  app-network:
    driver: bridge
```

#### Key Points
- The `app` service builds from the local `Dockerfile`.
- The `redis` service uses the official `redis:6.2` image.
- `depends_on` ensures the `redis` service starts before the `app` service.
- A named volume (`redis-data`) persists Redis data.
- A custom bridge network (`app-network`) enables communication between containers.

### 2. Docker Compose YAML Syntax
The Docker Compose YAML file uses a specific structure to define services, networks, and volumes. Let’s break down the syntax used in the `docker-compose.yml` above.

#### Key Elements Explained
- **`version: '3.8'`**: Specifies the Docker Compose file version (3.8 is compatible with recent Docker versions).
- **`services`**:
  - Defines the containers to run.
  - `app`:
    - `build: .`: Builds the image from the local `Dockerfile`.
    - `ports: ["3000:3000"]`: Maps port 3000 on the host to port 3000 in the container.
    - `environment`: Sets environment variables (e.g., `NODE_ENV=production`).
    - `depends_on: [redis]`: Ensures the `redis` service starts first.
    - `networks: [app-network]`: Attaches the service to the `app-network`.
  - `redis`:
    - `image: redis:6.2`: Pulls the `redis:6.2` image from Docker Hub.
    - `ports: ["6379:6379"]`: Exposes Redis on port 6379.
    - `volumes: [redis-data:/data]`: Mounts the `redis-data` volume to `/data` in the container.
    - `networks: [app-network]`: Attaches the service to the `app-network`.
- **`volumes`**:
  - `redis-data`: Declares a named volume for persisting Redis data.
- **`networks`**:
  - `app-network`: Creates a custom bridge network for container communication.

#### Additional Syntax Options
- `restart: always`: Restarts the container if it stops.
- `command: ["npm", "start"]`: Overrides the default command in the `Dockerfile`.
- `healthcheck`: Defines health checks for the service.

### 3. Managing Services with `docker-compose`
The `docker-compose` command-line tool helps you manage the lifecycle of your multi-container app, including starting, stopping, and inspecting services.

#### Common Commands
Using the `docker-compose.yml` above, let’s explore some key commands:
1. **Start Services:**
   ```bash
   docker-compose -f docker-compose.yml up -d
   ```
   - `-d` runs the containers in detached mode.
   Output:
   ```
   Creating network "docker-compose-demo_app-network" with driver "bridge"
   Creating volume "docker-compose-demo_redis-data" with default driver
   Creating docker-compose-demo_redis_1 ... done
   Creating docker-compose-demo_app_1   ... done
   ```
2. **Check Running Services:**
   ```bash
   docker-compose -f docker-compose.yml ps
   ```
   Output:
   ```
   Name                           Command               State           Ports
   --------------------------------------------------------------------------------
   docker-compose-demo_app_1     docker-entrypoint.sh node app.js   Up      0.0.0.0:3000->3000/tcp
   docker-compose-demo_redis_1   docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
   ```
3. **View Logs:**
   ```bash
   docker-compose -f docker-compose.yml logs app
   ```
   Output:
   ```
   app_1  | Server running on port 3000
   ```
4. **Stop Services:**
   ```bash
   docker-compose -f docker-compose.yml stop
   ```
   Output:
   ```
   Stopping docker-compose-demo_app_1   ... done
   Stopping docker-compose-demo_redis_1 ... done
   ```
5. **Remove Services and Resources:**
   ```bash
   docker-compose -f docker-compose.yml down -v
   ```
   - `-v` removes the volumes.
   Output:
   ```
   Removing docker-compose-demo_app_1   ... done
   Removing docker-compose-demo_redis_1 ... done
   Removing network docker-compose-demo_app-network
   Removing volume docker-compose-demo_redis-data
   ```

#### Test the App
After starting the services, access the app at `http://localhost:3000`. You should see "Hello from the Docker Compose Demo!".

### 4. Scaling Services
Docker Compose allows you to scale services to handle increased load by running multiple instances of a container. This is useful for load balancing and testing scalability.

#### Steps to Scale the `app` Service
1. Start the services (if not already running):
   ```bash
   docker-compose -f docker-compose.yml up -d
   ```
2. Scale the `app` service to 3 instances:
   ```bash
   docker-compose -f docker-compose.yml up -d --scale app=3
   ```
   Output:
   ```
   Starting docker-compose-demo_redis_1 ... done
   Creating docker-compose-demo_app_2   ... done
   Creating docker-compose-demo_app_3   ... done
   ```
3. Verify the scaled services:
   ```bash
   docker-compose -f docker-compose.yml ps
   ```
   Output:
   ```
   Name                           Command               State           Ports
   --------------------------------------------------------------------------------
   docker-compose-demo_app_1     docker-entrypoint.sh node app.js   Up      0.0.0.0:3000->3000/tcp
   docker-compose-demo_app_2     docker-entrypoint.sh node app.js   Up      0.0.0.0:3000->3000/tcp
   docker-compose-demo_app_3     docker-entrypoint.sh node app.js   Up      0.0.0.0:3000->3000/tcp
   docker-compose-demo_redis_1   docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
   ```
   - Note: All instances share the same port mapping (`3000`). Docker Compose automatically load balances requests across the instances.
4. Scale down to 1 instance:
   ```bash
   docker-compose -f docker-compose.yml up -d --scale app=1
   ```
   Output:
   ```
   Stopping and removing docker-compose-demo_app_2 ... done
   Stopping and removing docker-compose-demo_app_3 ... done
   ```
5. Verify the scaled-down services:
   ```bash
   docker-compose -f docker-compose.yml ps
   ```
   Output:
   ```
   Name                           Command               State           Ports
   --------------------------------------------------------------------------------
   docker-compose-demo_app_1     docker-entrypoint.sh node app.js   Up      0.0.0.0:3000->3000/tcp
   docker-compose-demo_redis_1   docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
   ```

#### Notes on Scaling
- Scaling with Docker Compose is limited to the same host and does not provide advanced orchestration features like Docker Swarm or Kubernetes.
- For production, consider using an external load balancer or orchestrator to manage scaled services.

## 🚀 Getting Started

To master Docker Compose:
1. Add `app.js`, `package.json`, `Dockerfile`, and `docker-compose.yml` to your project.
2. Define your multi-container app in `docker-compose.yml` and understand the YAML syntax.
3. Use `docker-compose` commands to start, stop, and manage your services.
4. Experiment with scaling the `app` service to see how Docker Compose handles multiple instances.
5. Access the app at `http://localhost:3000` to verify it’s working.

Docker Compose is a powerful tool for local development and testing multi-container apps. Move on to the next sections of the roadmap to explore Docker Swarm, Kubernetes, and advanced deployment strategies!