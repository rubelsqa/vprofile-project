#!/bin/bash
sudo systemctl stop Jenkins
sudo tar czf /tmp/jenkins_backup.tar.gz -C /var/lib/jenkins .
sudo aws s3 cp /tmp/jenkins_backup.tar.gz s3://cicd-data-vprofile/jenkins_backup.tar.gz
sudo rm /tmp/jenkins_backup.tar.gz
sudo shutdown now