#!/bin/bash

# Import Corretto key and install Corretto 17
sudo apt update
sudo apt install -y wget curl gnupg
wget -O- https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list
sudo apt update
sudo apt install -y java-17-amazon-corretto-jdk

# Create directories for Nexus
mkdir -p /opt/nexus/   
mkdir -p /tmp/nexus/                           

# Download and extract Nexus
cd /tmp/nexus/
NEXUSURL="https://download.sonatype.com/nexus/3/latest-unix.tar.gz"
wget $NEXUSURL -O nexus.tar.gz
sleep 10
EXTOUT=$(tar xzvf nexus.tar.gz)
NEXUSDIR=$(echo $EXTOUT | head -n 1 | cut -d '/' -f1)
sleep 5
rm -rf /tmp/nexus/nexus.tar.gz
sudo cp -r /tmp/nexus/* /opt/nexus/
sleep 5

# Create Nexus user and set permissions
sudo useradd nexus
sudo chown -R nexus:nexus /opt/nexus 

# Create systemd service for Nexus
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOT
[Unit]
Description=Nexus Service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/$NEXUSDIR/bin/nexus start
ExecStop=/opt/nexus/$NEXUSDIR/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

# Configure Nexus to run as the 'nexus' user
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/$NEXUSDIR/bin/nexus.rc

# Reload systemd, start and enable Nexus service
sudo systemctl daemon-reload
sudo systemctl enable nexus

# Restore Backup from S3
sudo apt install maven wget unzip -y
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
cd ~
sudo apt-get update
cd /opt/
sudo rm -rf /opt/nexus
sudo aws s3 cp s3://cicd-data-vprofile/nexus_backup.tar.gz /opt/
sudo tar xzvf nexus_backup.tar.gz
sudo rm -rf /opt/nexus_backup.tar.gz
sudo chown nexus.nexus /opt/nexus -R
sudo systemctl start nexus