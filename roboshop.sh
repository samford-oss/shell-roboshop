#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0c550dd13db8bcafc"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z09956772F3AG5T9NT00Q"
DOMAIN_NAME="samali.xyz"

for instance in "${INSTANCES[@]}"
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami_09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg_0c550dd13db8bcafc --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query "Instances[0].InstanceID" --output text)
    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi
    echo "$instance IP address: $IP"
done