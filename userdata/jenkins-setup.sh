#!/bin/bash
sudo apt update -y
sudo apt install openjdk-11-jdk -y
sudo apt install maven wget unzip -y
sudo apt install nodejs -y
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
cd ~
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins -y
sleep 30
sudo systemctl stop jenkins
sleep 30
cd /var/lib/
sudo rm -rf /var/lib/jenkins
sudo aws s3 cp s3://cicd-data-vprofile/jenkins_backup.tar.gz /var/lib/
sudo mkdir -p jenkins
sudo tar xzvf jenkins_backup.tar.gz -C jenkins
sudo rm -rf /var/lib/jenkins_backup.tar.gz
sudo chown jenkins.jenkins /var/lib/jenkins -R
sudo systemctl start jenkins
###