# #!/bin/bash
# sudo apt update

# # SSH_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDaBSpmz07+rUAG//8rrPxDztMN3a9yGCuzDGseWlUi1IuPcXflCeQoOhQZsVExxxHaRgtP8BU/U/6ETbk6fqbFRge5iT7xp28sqWLaBF9bv3RbSpZOrVunNwn2v6eZCXwulMn53YtdUZRHJlquf7keKwhqDWTF4RhGdret+5qQNCC6VaiMsYXkwLayxwrupz7X75SIovHcw+zkby/jF/woSDtzY9OjAAuIQXljpOwvCHYneHRSxhmY7Ca1X7dXgREVz51LSXf1SzbryTF5cGSRBFElg4bEi6uthUeveTaduy3WD0dI5hdQpjFJBcCVWWyyS2TKH0KxXISXIO48y05n"

# # echo "$SSH_PUBKEY" >> /home/ubuntu/.ssh/authorized_keys

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
# echo "added ${USER} and ubuntu to docker group"
# sleep 1
# newgrp docker

# groups root
# groups ubuntu