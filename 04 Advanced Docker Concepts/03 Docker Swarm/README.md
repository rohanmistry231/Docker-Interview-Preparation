# 🧩 Docker Swarm

This section covers Docker Swarm, a native orchestration tool for managing a cluster of Docker nodes. You’ll learn how to set up a Swarm cluster, manage services and stacks, scale services with load balancing, and ensure high availability. These techniques are essential for running distributed applications in production. Let’s explore each topic with a practical example using a Node.js app!

## 🏗️ Sub-Topics

### 1. Setting Up a Swarm Cluster
Docker Swarm turns a group of Docker hosts into a single virtual host, enabling container orchestration. You need at least one manager node and can add worker nodes for scalability.

#### Hands-On Example: Setting Up a Three-Node Swarm Cluster
We’ll set up a Swarm cluster with one manager and two worker nodes using a script.

##### Supporting Files
**setup-swarm.sh**
```bash
#!/bin/bash

# Initialize Swarm on the manager node
echo "Initializing Swarm on manager node..."
docker swarm init --advertise-addr 192.168.1.100

# Get the join token for workers
WORKER_TOKEN=$(docker swarm join-token -q worker)

# Join worker nodes (replace IPs with your worker node IPs)
echo "Joining worker1 to the Swarm..."
ssh user@192.168.1.101 "docker swarm join --token $WORKER_TOKEN 192.168.1.100:2377"

echo "Joining worker2 to the Swarm..."
ssh user@192.168.1.102 "docker swarm join --token $WORKER_TOKEN 192.168.1.100:2377"

# Verify the cluster
echo "Swarm cluster nodes:"
docker node ls
```

#### Steps to Set Up the Swarm Cluster
1. Ensure Docker is installed on all nodes (manager: 192.168.1.100, workers: 192.168.1.101, 192.168.1.102).
2. Set up SSH access between nodes (or run commands manually on each node).
3. Make the script executable:
   ```bash
   chmod +x setup-swarm.sh
   ```
4. Run the script on the manager node:
   ```bash
   ./setup-swarm.sh
   ```
   Example Output:
   ```
   Initializing Swarm on manager node...
   Swarm initialized: current node (xyz) is now a manager.
   Joining worker1 to the Swarm...
   This node joined a swarm as a worker.
   Joining worker2 to the Swarm...
   This node joined a swarm as a worker.
   Swarm cluster nodes:
   ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
   abc123def456 *                manager1            Ready               Active              Leader
   789def123abc                  worker1             Ready               Active
   456ghi789jkl                  worker2             Ready               Active
   ```
   - Replace `192.168.1.100`, `192.168.1.101`, and `192.168.1.102` with your actual node IPs.
   - Replace `user` with your SSH user.

### 2. Managing Services and Stacks
Docker Swarm allows you to manage services (individual containers) and stacks (groups of services defined in a Compose file). Stacks simplify deployment of multi-container apps.

#### Example: Deploying a Stack with a Node.js App
We’ll deploy a stack with a Node.js app and a Redis service.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    res.send('Hello from the Docker Swarm Demo!');
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "docker-swarm-demo",
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

**docker-stack.yml**
```yaml
version: '3.8'

services:
  app:
    image: docker-swarm-demo:latest
    ports:
      - "3000:3000"
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
    environment:
      - NODE_ENV=production

  redis:
    image: redis:6.2
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
```

#### Steps to Deploy the Stack
1. Build the app image on the manager node:
   ```bash
   docker build -t docker-swarm-demo:latest .
   ```
2. Deploy the stack:
   ```bash
   docker stack deploy -c docker-stack.yml swarm-demo
   ```
3. Verify the services:
   ```bash
   docker stack services swarm-demo
   ```
   Example Output:
   ```
   ID                  NAME                MODE                REPLICAS            IMAGE                  PORTS
   abc123def456        swarm-demo_app      replicated          3/3                 docker-swarm-demo:latest   *:3000->3000/tcp
   789def123abc        swarm-demo_redis    replicated          1/1                 redis:6.2
   ```
4. Access the app at `http://192.168.1.100:3000` (or the IP of any node). You should see:
   ```
   Hello from the Docker Swarm Demo!
   ```

### 3. Scaling and Load Balancing
Docker Swarm allows you to scale services and automatically load balances traffic across replicas using its built-in routing mesh.

#### Steps to Scale the App Service
1. Scale the `app` service to 5 replicas:
   ```bash
   docker service scale swarm-demo_app=5
   ```
   Output:
   ```
   swarm-demo_app scaled to 5
   ```
2. Verify the replicas:
   ```bash
   docker service ls
   ```
   Output:
   ```
   ID                  NAME                MODE                REPLICAS            IMAGE                  PORTS
   abc123def456        swarm-demo_app      replicated          5/5                 docker-swarm-demo:latest   *:3000->3000/tcp
   789def123abc        swarm-demo_redis    replicated          1/1                 redis:6.2
   ```
3. Make multiple requests to test load balancing:
   ```bash
   for i in {1..5}; do curl http://192.168.1.100:3000; done
   ```
   - Swarm’s routing mesh distributes requests across the 5 replicas.
4. Inspect the service to see the replicas:
   ```bash
   docker service ps swarm-demo_app
   ```
   Output:
   ```
   ID                  NAME                IMAGE                  NODE                DESIRED STATE       CURRENT STATE
   123abc456def        swarm-demo_app.1    docker-swarm-demo:latest   manager1            Running             Running 5 minutes ago
   456def789ghi        swarm-demo_app.2    docker-swarm-demo:latest   worker1             Running             Running 5 minutes ago
   789ghi123jkl        swarm-demo_app.3    docker-swarm-demo:latest   worker2             Running             Running 5 minutes ago
   321jkl654mno        swarm-demo_app.4    docker-swarm-demo:latest   worker1             Running             Running 1 minute ago
   654mno987pqr        swarm-demo_app.5    docker-swarm-demo:latest   worker2             Running             Running 1 minute ago
   ```

#### Notes on Load Balancing
- Swarm’s routing mesh listens on the published port (`3000`) on all nodes and routes traffic to available replicas.
- For external load balancing, you can place a reverse proxy (e.g., NGINX) in front of the Swarm cluster.

### 4. High Availability with Swarm
Docker Swarm ensures high availability by distributing replicas across nodes and automatically recovering from failures. Manager nodes maintain the cluster state using a Raft consensus algorithm.

#### Steps to Test High Availability
1. Simulate a worker node failure (e.g., stop Docker on `worker1`):
   ```bash
   ssh user@192.168.1.101 "sudo systemctl stop docker"
   ```
2. Check the cluster state:
   ```bash
   docker node ls
   ```
   Output:
   ```
   ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
   abc123def456 *                manager1            Ready               Active              Leader
   789def123abc                  worker1             Down                Active
   456ghi789jkl                  worker2             Ready               Active
   ```
3. Verify the service replicas:
   ```bash
   docker service ps swarm-demo_app
   ```
   Output:
   ```
   ID                  NAME                IMAGE                  NODE                DESIRED STATE       CURRENT STATE
   123abc456def        swarm-demo_app.1    docker-swarm-demo:latest   manager1            Running             Running 10 minutes ago
   456def789ghi        swarm-demo_app.2    docker-swarm-demo:latest   worker2             Running             Running 3 minutes ago
   789ghi123jkl        swarm-demo_app.3    docker-swarm-demo:latest   worker2             Running             Running 3 minutes ago
   321jkl654mno        swarm-demo_app.4    docker-swarm-demo:latest   worker2             Running             Running 3 minutes ago
   654mno987pqr        swarm-demo_app.5    docker-swarm-demo:latest   worker2             Running             Running 3 minutes ago
   ```
   - Swarm reschedules the replicas from `worker1` to `worker2`.
4. Access the app at `http://192.168.1.100:3000`—it should still work, demonstrating high availability.
5. Restart the worker node:
   ```bash
   ssh user@192.168.1.101 "sudo systemctl start docker"
   ```
   - Swarm will rebalance the replicas across available nodes.

#### Manager High Availability
- To ensure manager high availability, add more manager nodes (at least 3 for Raft consensus):
  ```bash
  docker node promote worker1
  docker node promote worker2
  ```
- If the leader manager fails, another manager takes over as the leader.

## 🚀 Getting Started

To master Docker Swarm:
1. Add `app.js`, `package.json`, `Dockerfile`, `docker-stack.yml`, and `setup-swarm.sh` to your project.
2. Set up the Swarm cluster using `setup-swarm.sh` with at least three nodes.
3. Deploy the stack using `docker-stack.yml` and access the app at `http://<node-ip>:3000`.
4. Scale the `app` service and test load balancing with multiple requests.
5. Simulate node failures to test high availability and verify the app remains accessible.
6. Clean up by removing the stack and leaving the Swarm:
   ```bash
   docker stack rm swarm-demo
   docker swarm leave --force
   ```

Docker Swarm provides a simple yet powerful way to orchestrate containers. Move on to the next sections of the roadmap to explore Kubernetes, advanced Docker concepts, and more!