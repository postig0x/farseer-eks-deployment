#!/bin/bash
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
docker swarm init --advertise-addr $(hostname -i)
# save token
docker swarm join-token -q worker > worker.token

for ip in "${worker_ips[@]}"
do
  echo "copying worker.token to ${ip}"
  scp -i /home/ubuntu/.ssh/dev_key.pem worker.token ubuntu@${ip}:/home/ubuntu
done

# login to docker hub
echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin
