#!/bin/bash -xe

for attempt in 1 2 3; do
    if [ ! -z "`which ansible`" ]; then
        break
    fi
    echo "Trying to install git, attempt $attempt"
    sudo apt-get update -yq --fix-missing
    sudo apt-get install -yq ansible
done
git -C /home/ubuntu/ clone https://github.com/gaearaz/DevOps-RampUp-Res.git

#sudo apt-add-repository ppa:ansible/ansible -y && sudo apt update
#sudo apt install ansible python3-pip python-pip -y
# sudo pip install boto
#git -C /home/ubuntu/ clone https://github.com/gaearaz/DevOps-RampUp-Res.git