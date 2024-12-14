#!/bin/bash
# inputs needed
# ${node_ips[@]} - array of frontend and backend private IPS
# ${dev_key} - ssh key for manager node to pass token to worker nodes
# ${DOCKER_CREDS_USR} - docker hub username
# ${DOCKER_CREDS_PSW} - docker hub password
# ${XAI_KEY} - openai api key

sudo apt update

# add ssh key for manager node to pass token to worker nodes
echo "${dev_key}" > /home/ubuntu/.ssh/dev_key.pem
chmod 600 /home/ubuntu/.ssh/dev_key.pem

#     _         _           
#  __| |___  __| |_____ _ _ 
# / _` / _ \/ _| / / -_) '_|
# \__,_\___/\__|_\_\___|_|  
# docker gpg key
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# add repo to apt sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

# install docker

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo groupadd docker

sudo usermod -aG docker $USER

#  _ __  __ _ _ _ 
# | '  \/ _` | '_|
# |_|_|_\__, |_|  
#       |___/     
# swarm manager
private_ip=$(hostname -i | awk '{print $1; exit}')
sudo docker swarm init --advertise-addr $private_ip
# save token
sudo docker swarm join-token -q worker > worker.token

for worker in "$node_ips[@]"
do
  ssh -i /home/ubuntu/.ssh/dev_key.pem ubuntu@$worker "sudo docker swarm join \
    --token \$(cat /home/ubuntu/worker.token) \"$private_ip\":2377"
done

# login to docker hub
echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin

# create overlay network for services
docker network create --driver overlay devnet

# create frontend service for frontend node
docker service create \
  --name frontend \
  --replicas 1 \
  --constraint 'node.hostname == ${node_ips[0]}' \
  --publish published=3000,target=3000 \
  --network devnet \
  cloudbandits/farseer_front:latest

# create backend service for backend node
docker service create \
  --name backend \
  --replicas 1 \
  --constraint 'node.hostname == ${node_ips[1]}' \ # ip-123-12-12-12 format
  --publish published=8000,target=8000 \
  --env XAI_KEY=${XAI_KEY} \
  --network devnet \
  cloudbandits/farseer_back:latest
