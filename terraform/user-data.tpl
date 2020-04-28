#!/bin/bash -xe
sudo apt-add-repository ppa:ansible/ansible -y && sudo apt update
sudo apt install ansible python3-pip python-pip -y
# sudo pip install boto
git -C /home/ubuntu/ clone https://github.com/gaearaz/DevOps-RampUp-Res.git