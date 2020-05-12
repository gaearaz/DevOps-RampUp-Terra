#!/bin/bash -xe

for attempt in 1 2 3; do
    if [ ! -z "`which jenkins`" ]; then
        break
    fi
    echo "Trying to install git, attempt $attempt"
    sudo apt-get update -yq --fix-missing
    sudo apt install -yq openjdk-8-jdk
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
    sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    sudo apt update
    sudo apt-get install -yq jenkins
    sudo ufw allow 8080
done
