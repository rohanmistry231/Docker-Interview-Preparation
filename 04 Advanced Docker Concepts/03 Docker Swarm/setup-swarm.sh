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