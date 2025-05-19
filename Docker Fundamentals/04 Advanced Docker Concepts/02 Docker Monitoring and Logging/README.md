# 📈 Docker Monitoring and Logging

This section covers essential techniques for monitoring and logging Docker containers, ensuring you can track performance and troubleshoot issues effectively. You’ll learn how to access container logs with `docker logs`, monitor resource usage with `docker stats`, integrate with Prometheus and Grafana for advanced monitoring, and set up centralized logging with the ELK Stack. Let’s explore these concepts with a practical example using a Node.js app!

## 🏗️ Sub-Topics

### 1. Container Logs with `docker logs`
Docker captures the standard output (stdout) and standard error (stderr) of containers, which can be accessed using the `docker logs` command. This is useful for debugging and monitoring application behavior.

#### Hands-On Example: Node.js App with Logging
We’ll create a Node.js app that generates logs periodically.

##### Supporting Files
**app.js**
```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
    console.log(`[${new Date().toISOString()}] Request to / endpoint`);
    res.send('Hello from the Monitoring and Logging Demo!');
});

app.get('/metrics', (req, res) => {
    console.log(`[${new Date().toISOString()}] Request to /metrics endpoint`);
    res.json({
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    });
});

const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
```

**package.json**
```json
{
    "name": "monitoring-logging-demo",
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
    networks:
      - monitoring-network

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - monitoring-network

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3001:3000"
    volumes:
      - ./grafana-datasource.yml:/etc/grafana/provisioning/datasources/datasource.yml
    networks:
      - monitoring-network

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    networks:
      - monitoring-network

  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    depends_on:
      - elasticsearch
    networks:
      - monitoring-network

  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    networks:
      - monitoring-network

networks:
  monitoring-network:
    driver: bridge
```

#### Steps to View Logs
1. Start the services:
   ```bash
   docker-compose -f docker-compose.yml up -d
   ```
   Output:
   ```
   Creating network "monitoring-logging-demo_monitoring-network" with driver "bridge"
   Creating monitoring-logging-demo_app_1         ... done
   Creating monitoring-logging-demo_elasticsearch_1 ... done
   Creating monitoring-logging-demo_prometheus_1    ... done
   Creating monitoring-logging-demo_grafana_1       ... done
   Creating monitoring-logging-demo_logstash_1      ... done
   Creating monitoring-logging-demo_kibana_1        ... done
   ```
2. Make requests to generate logs:
   ```bash
   curl http://localhost:3000
   curl http://localhost:3000/metrics
   ```
3. View the logs:
   ```bash
   docker logs monitoring-logging-demo_app_1
   ```
   Example Output:
   ```
   Server running on port 3000
   [2025-05-19T02:54:00.123Z] Request to / endpoint
   [2025-05-19T02:54:05.456Z] Request to /metrics endpoint
   ```
   - Timestamps are in UTC (IST - 5:30 hours, so 08:24 AM IST = 02:54 AM UTC).

### 2. Monitoring with Docker Stats
The `docker stats` command provides real-time resource usage statistics for running containers, including CPU, memory, and network I/O.

#### Steps to Monitor with Docker Stats
1. List running containers:
   ```bash
   docker ps
   ```
   Output:
   ```
   CONTAINER ID   IMAGE         NAME                           PORTS
   abc123def456   node-app      monitoring-logging-demo_app_1         0.0.0.0:3000->3000/tcp
   789def123abc   prom/prometheus   monitoring-logging-demo_prometheus_1   0.0.0.0:9090->9090/tcp
   ...
   ```
2. Monitor resource usage:
   ```bash
   docker stats monitoring-logging-demo_app_1
   ```
   Example Output:
   ```
   CONTAINER ID   NAME                           CPU %     MEM USAGE / LIMIT   MEM %     NET I/O         BLOCK I/O
   abc123def456   monitoring-logging-demo_app_1   0.02%     25.3MiB / 8GiB      0.31%     1.2kB / 1.5kB   0B / 0B
   ```
   - This shows the app is using minimal CPU and memory, with light network I/O.

### 3. Integrating with Prometheus and Grafana
Prometheus and Grafana are powerful tools for monitoring Docker containers. Prometheus collects metrics, and Grafana visualizes them in dashboards.

#### Configuration Files
**prometheus.yml**
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:3000']
```

**grafana-datasource.yml**
```yaml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus:9090
    access: proxy
    isDefault: true
```

#### Steps to Set Up Prometheus and Grafana
1. The `docker-compose.yml` already includes Prometheus and Grafana services.
2. Access Prometheus at `http://localhost:9090` to verify it’s scraping metrics from the app (`app:3000`).
3. Access Grafana at `http://localhost:3001` (default credentials: admin/admin).
4. In Grafana, create a new dashboard and add a panel to visualize the `uptime` metric from the `/metrics` endpoint:
   - Query: `uptime`
   - This will show the app’s uptime over time.

#### Notes
- The app exposes metrics at `/metrics`, but in a real scenario, you’d use a library like `prom-client` to expose Prometheus-compatible metrics.
- Prometheus scrapes the app every 15 seconds, as defined in `prometheus.yml`.

### 4. Centralized Logging (ELK Stack)
The ELK Stack (Elasticsearch, Logstash, Kibana) provides a centralized logging solution. Logstash collects logs, Elasticsearch stores and indexes them, and Kibana visualizes them.

#### Configuration
The `docker-compose.yml` already sets up the ELK Stack. We need a Logstash configuration to collect logs from the app.

**logstash.conf**
```plaintext
input {
  tcp {
    port => 5000
    codec => json_lines
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "app-logs-%{+YYYY.MM.dd}"
  }
}
```

#### Steps to Set Up Centralized Logging
1. Modify the app to send logs to Logstash (in a real scenario, you’d use a logging driver or a library like `winston` to send logs to Logstash). For simplicity, we’ll assume the app logs to stdout, and Logstash collects Docker logs via a logging driver.
2. Update the `docker-compose.yml` to use the `json-file` logging driver (default in Docker) and configure Logstash to read from it (in production, you’d use a more direct method).
3. Access Kibana at `http://localhost:5601`.
4. In Kibana, create an index pattern (`app-logs-*`) to view logs.
5. View the logs in Kibana’s Discover tab. Example log entry:
   ```
   {
     "message": "[2025-05-19T02:54:00.123Z] Request to / endpoint",
     "container": "monitoring-logging-demo_app_1",
     "@timestamp": "2025-05-19T02:54:00.123Z"
   }
   ```

#### Notes
- For production, configure the `app` service to use the `gelf` or `fluentd` logging driver to send logs directly to Logstash.
- Example `gelf` logging driver configuration:
  ```yaml
  app:
    logging:
      driver: gelf
      options:
        gelf-address: "udp://logstash:12201"
  ```

## 🚀 Getting Started

To set up monitoring and logging:
1. Add `app.js`, `package.json`, `Dockerfile`, `docker-compose.yml`, `prometheus.yml`, and `grafana-datasource.yml` to your project.
2. Start the services with `docker-compose -f docker-compose.yml up -d`.
3. Use `docker logs` and `docker stats` to monitor the app locally.
4. Access Prometheus (`http://localhost:9090`) and Grafana (`http://localhost:3001`) to visualize metrics.
5. Set up centralized logging with the ELK Stack and view logs in Kibana (`http://localhost:5601`).
6. Make requests to `http://localhost:3000` and `http://localhost:3000/metrics` to generate logs and metrics.

These monitoring and logging techniques will help you keep your Dockerized applications running smoothly. Move on to the next sections of the roadmap to explore advanced Docker concepts, Kubernetes, and more!