#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-0c550dd13db8bcafc"
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z09956772F3AG5T9NT00Q"
DOMAIN_NAME="samali.xyz"

for instance in "${INSTANCES[@]}"
do
  INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-0c550dd13db8bcafc --query 'Instances[0].InstanceId' --output text)

  echo "Launched instance $instance with ID $INSTANCE_ID. Waiting for it to be running..."

  # Wait for instance to be in running state
  aws ec2 wait instance-running --instance-ids $INSTANCE_ID

  if [ "$instance" != "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
  else
    IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
  fi

  echo "$instance IP address: $IP"
done