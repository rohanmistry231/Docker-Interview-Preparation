# 🌐 Docker Networking

This section explores Docker networking concepts, which are crucial for enabling communication between containers, exposing services to the host or external networks, and managing service discovery. You'll learn about different network types (Bridge, Host, Overlay), how to expose ports, connect containers, and leverage DNS for service discovery. Let’s dive into practical examples to understand these concepts!

## 🏗️ Sub-Topics

### 1. Bridge, Host, and Overlay Networks
Docker provides several network drivers to control how containers communicate with each other and the outside world. The most common types are Bridge, Host, and Overlay networks.

#### Bridge Network
- The default network type for Docker containers.
- Creates an isolated network on the host, with containers attached to it.
- Containers on the same bridge network can communicate using their IP addresses or container names (via Docker’s built-in DNS).
- Suitable for single-host container communication.

**Example: Bridge Network with Docker Compose**
**docker-compose-bridge.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    networks:
      - bridge-net

networks:
  bridge-net:
    driver: bridge
```

#### Host Network
- Removes network isolation between the container and the host.
- The container shares the host’s network stack, using the host’s IP address and ports directly.
- No port mapping (`ports`) is needed since the container uses the host’s network.
- Useful for scenarios requiring maximum network performance, but reduces isolation.

**Example: Host Network with Docker Compose**
**docker-compose-host.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    network_mode: host
```

#### Overlay Network
- Designed for multi-host networking, often used with Docker Swarm or Kubernetes.
- Creates a distributed network across multiple Docker hosts, allowing containers on different hosts to communicate.
- Requires Docker Swarm mode to be initialized.
- Suitable for clustered environments.

**Example: Overlay Network with Docker Compose (Swarm Mode)**
**docker-compose-overlay.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    networks:
      - overlay-net

networks:
  overlay-net:
    driver: overlay
```

#### Steps to Test Overlay Network
1. Initialize Docker Swarm on your host:
   ```bash
   docker swarm init
   ```
2. Deploy the stack:
   ```bash
   docker stack deploy -c docker-compose-overlay.yml demo-stack
   ```
3. Verify the network:
   ```bash
   docker network ls
   ```
   Output:
   ```
   NETWORK ID     NAME               DRIVER    SCOPE
   123abc456def   bridge             bridge    local
   789def123abc   demo-stack_overlay-net   overlay   swarm
   ```

### 2. Exposing Ports
Exposing ports allows containers to accept external connections, either from the host or other networks.

- **EXPOSE Instruction (Dockerfile):** Documents the port a container listens on (does not publish the port).
- **Port Mapping (Runtime):** Publishes the port to the host using the `-p` flag or `ports` in Docker Compose.

#### Using the Bridge Network Example
The `docker-compose-bridge.yml` above maps port `3000` on the host to port `3000` in the container:
```yaml
ports:
  - "3000:3000"
```

#### Steps to Test Port Exposure
1. Start the services:
   ```bash
   docker-compose -f docker-compose-bridge.yml up -d
   ```
2. Access the app at `http://localhost:3000`. You should see "Hello from the Docker Networking Demo!".
3. Verify the port mapping:
   ```bash
   docker ps
   ```
   Output:
   ```
   CONTAINER ID   IMAGE          COMMAND                  PORTS                    NAMES
   abc123def456   demo-app       "docker-entrypoint.s…"   0.0.0.0:3000->3000/tcp   demo-app-1
   ```

#### Using Host Network (No Port Mapping Needed)
Since the `docker-compose-host.yml` uses the host network, the container directly uses the host’s port `3000`:
1. Start the services:
   ```bash
   docker-compose -f docker-compose-host.yml up -d
   ```
2. Access the app at `http://localhost:3000`.
3. Verify (no port mapping in `docker ps` output):
   ```bash
   docker ps
   ```
   Output:
   ```
   CONTAINER ID   IMAGE          COMMAND                  PORTS   NAMES
   789def123abc   demo-app       "docker-entrypoint.s…"           demo-app-1
   ```

### 3. Connecting Containers
Containers on the same user-defined network can communicate with each other using their container names or service names (via Docker’s DNS).

#### Example: Connecting Containers with Docker Compose
**docker-compose-connect.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    networks:
      - connect-net

  redis:
    image: redis:6.2
    ports:
      - "6379:6379"
    networks:
      - connect-net

networks:
  connect-net:
    driver: bridge
```

#### Steps to Test Container Connectivity
1. Start the services:
   ```bash
   docker-compose -f docker-compose-connect.yml up -d
   ```
2. Verify the services are running:
   ```bash
   docker-compose -f docker-compose-connect.yml ps
   ```
   Output:
   ```
   Name                     Command               State           Ports
   --------------------------------------------------------------------------------
   app_1     docker-entrypoint.sh node app.js   Up      0.0.0.0:3000->3000/tcp
   redis_1   docker-entrypoint.sh redis ...   Up      0.0.0.0:6379->6379/tcp
   ```
3. Test connectivity by pinging the `redis` service from the `app` container:
   ```bash
   docker exec -it demo-app-1 ping redis -c 4
   ```
   Output:
   ```
   PING redis (172.20.0.3): 56 data bytes
   64 bytes from 172.20.0.3: seq=0 ttl=64 time=0.123 ms
   64 bytes from 172.20.0.3: seq=1 ttl=64 time=0.089 ms
   64 bytes from 172.20.0.3: seq=2 ttl=64 time=0.092 ms
   64 bytes from 172.20.0.3: seq=3 ttl=64 time=0.087 ms
   ```

### 4. DNS and Service Discovery
Docker provides built-in DNS for service discovery within user-defined networks, allowing containers to resolve each other by their service names.

#### Using the Connecting Containers Example
In the `docker-compose-connect.yml`, the `app` and `redis` services are on the same `connect-net` network. Docker’s DNS allows the `app` container to resolve the `redis` service by its name (`redis`).

#### How It Works
- Docker runs a DNS server on each container’s network, listening on `127.0.0.11:53`.
- Containers on the same user-defined network (e.g., `connect-net`) can resolve each other’s names to IP addresses.
- The service name (e.g., `redis`) acts as a hostname.

#### Test DNS Resolution
1. From the `app` container, resolve the `redis` service:
   ```bash
   docker exec -it demo-app-1 nslookup redis
   ```
   Output:
   ```
   Server:         127.0.0.11
   Address:        127.0.0.11#53

   Name:   redis
   Address: 172.20.0.3
   ```
   - `172.20.0.3` is the IP address of the `redis` container on the `connect-net` network.

2. If the `app` service needed to connect to Redis (e.g., using a Redis client), it could use the hostname `redis` directly:
   ```javascript
   const redis = require('redis');
   const client = redis.createClient({ url: 'redis://redis:6379' });
   ```

#### Notes on DNS
- Docker’s DNS only works within user-defined networks (not the default `bridge` network).
- Containers on different networks cannot resolve each other unless explicitly configured.
- Overlay networks in Swarm mode extend DNS across multiple hosts.

## 🚀 Getting Started

To master Docker networking:
1. Use the `docker-compose-bridge.yml` example to set up a Bridge network and test port exposure.
2. Experiment with the `docker-compose-host.yml` example to understand Host networking.
3. Set up Docker Swarm and deploy the `docker-compose-overlay.yml` example to explore Overlay networks.
4. Use the `docker-compose-connect.yml` example to connect containers and test DNS/service discovery.
5. Experiment with additional networking commands (e.g., `docker network ls`, `docker network inspect`) to deepen your understanding.

These networking concepts are essential for building scalable, multi-container applications with Docker. Move on to the next sections of the roadmap to explore Docker Compose, CI/CD integration, and more!

#### Supporting Files for All Examples
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the Docker Networking Demo!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "docker-networking-demo",
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