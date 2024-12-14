# #!/bin/bash

# # update system repos
# sudo apt update

# #        _    
# #  _____| |_  
# # (_-<_-< ' \ 
# # /__/__/_||_|
# # # add ssh key for manager node to pass token to worker nodes
# echo "${ssh_private_key}" > /home/ubuntu/.ssh/${key_name}.pem # Changed from dev_key import from Jenkins to use terraform generated EC2 SSH key
# # ssh-keygen -p -m PEM -f /home/ubuntu/.ssh/dev_key.pem
# # chown ubuntu:ubuntu /home/ubuntu/.ssh/dev_key.pem
# chown ubuntu:ubuntu /home/ubuntu/.ssh/${key_name}.pem
# chmod 400 /home/ubuntu/.ssh/${key_name}.pem

# # # chop up dev_key to make realkey
# # cat /home/ubuntu/.ssh/dev_key.pem | cut -d' ' -f1-4 > /home/ubuntu/.ssh/realkey.pem
# # tr ' ' '\n' < /home/ubuntu/.ssh/dev_key.pem | sed -n '5,29p' >> /home/ubuntu/.ssh/realkey.pem
# # printf "%s" "$(cat /home/ubuntu/.ssh/dev_key.pem | cut -d' ' -f30-)" >> /home/ubuntu/.ssh/realkey.pem

# # # ensure pem status
# # ssh-keygen -p -m PEM -f /home/ubuntu/.ssh/realkey.pem

# # # perms
# # chmod 400 /home/ubuntu/.ssh/realkey.pem

# #     _         _           
# #  __| |___  __| |_____ _ _ 
# # / _` / _ \/ _| / / -_) '_|
# # \__,_\___/\__|_\_\___|_|  
# # docker gpg key
# sudo apt install -y ca-certificates curl
# sudo install -m 0755 -d /etc/apt/keyrings
# sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

# # add repo to apt sources
# echo \
#   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
#   $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
#   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# sudo apt update

# # install docker

# sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# sudo groupadd docker

# sudo usermod -aG docker $USER
# sleep 1
# echo "sleeping.."
# sleep 1
# sudo usermod -aG docker ubuntu

# newgrp docker

# groups root
# groups ubuntu

# sleep 3
# echo "slept 3"
# #            _          
# #  _ _  __ _(_)_ _ __ __
# # | ' \/ _` | | ' \\ \ /
# # |_||_\__, |_|_||_/_\_\
# #      |___/            
# # install nginx
# sudo apt install -y nginx

# sleep 3
# echo "slept 3 after installing nginx"
# cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.bkp
# # modify nginx config (/etc/nginx/sites-enabled/default)
# sudo sed -i "/location \/ {/,/}/c\    location / {\n        proxy_pass http://${front_ip}:3000;\n        proxy_set_header Host \$host;\n        proxy_set_header X-Real-IP \$proxy_add_x_forwarded_for;\n    }" /etc/nginx/sites-enabled/default



# echo "nginx config modified"

# # start and enable nginx
# sudo systemctl start nginx
# sudo systemctl enable nginx

# echo "nginx started and enabled"

# #  _ __  __ _ _ _ 
# # | '  \/ _` | '_|
# # |_|_|_\__, |_|  
# #       |___/     
# # swarm manager
# private_ip=$(hostname -i | awk '{print $1; exit}')
# sudo docker swarm init --advertise-addr "$private_ip"
# # save token
# sudo docker swarm join-token -q worker > /home/ubuntu/worker.token
# echo "swarm manager init and token saved at /home/ubuntu/worker.token"

# echo "exporting worker token to use on worker nodes"
# export WORKER_TOKEN=$(cat /home/ubuntu/worker.token)

# sleep 5

# echo "Adding Frontend Private IP to known_hosts file."
# ssh-keyscan -H "${front_ip}" >> ~/.ssh/known_hosts
# ssh-keyscan -H "${front_ip}" >> /home/ubuntu/.ssh/known_hosts

# echo "Adding Backend Private IP to known_hosts file."
# ssh-keyscan -H ${back_ip} >> ~/.ssh/known_hosts
# ssh-keyscan -H "${back_ip}" >> /home/ubuntu/.ssh/known_hosts

# sleep 30

# echo "slept 30 after keyscan for frontend and backend"
# echo "waiting for frontend and backend instances to finish set up"

# ssh -i /home/ubuntu/.ssh/"${key_name}".pem ubuntu@"${front_ip}" "docker swarm join --token $WORKER_TOKEN $private_ip:2377"

# sleep 5
# echo "slept 5 after ssh 1"

# ssh -i /home/ubuntu/.ssh/"${key_name}".pem ubuntu@"${back_ip}" "docker swarm join --token $WORKER_TOKEN $private_ip:2377"

# sleep 5
# echo "slept 5 after ssh 2"

# # login to docker hub
# echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin

# # create overlay network for services
# sudo docker network create --driver overlay devnet
# echo "docker network created"

# # format node IPs to ip-0-0-0-0 format
# # used for createing docker services
# frontend_ip="ip-${front_ip}"
# frontend_ip=$(echo $frontend_ip | sed 's/\./\-/g')

# backend_ip="ip-${back_ip}"
# backend_ip=$(echo $backend_ip | sed 's/\./\-/g')

# echo "frontend_ip: $frontend_ip"
# echo "backend_ip: $backend_ip"

# # create frontend service for frontend node
# sudo docker service create \
#   --name frontend \
#   --replicas 1 \
#   --constraint "node.hostname==$frontend_ip" \
#   --publish published=3000,target=3000 \
#   --network devnet \
#   cloudbandits/farseer_front:latest

# echo "frontend service created"

# # create backend service for backend node
# sudo docker service create \
#   --name backend \
#   --replicas 1 \
#   --constraint "node.hostname==$backend_ip" \
#   --publish published=8000,target=8000 \
#   --env XAI_KEY=${XAI_KEY} \
#   --network devnet \
#   cloudbandits/farseer_back:latest

# echo "backend service created"

# sudo systemctl restart nginx
# sleep 10

# #                        _   
# #  _____ ___ __  ___ _ _| |_ 
# # / -_) \ / '_ \/ _ \ '_|  _|
# # \___/_\_\ .__/\___/_|  \__|
# #         |_| 
# # ubuntu owner
# # chown ubuntu:ubuntu /home/ubuntu/.ssh/realkey.pem
