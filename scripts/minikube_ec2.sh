#!/bin/bash

GET_INSTANCE_ID=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output text)

for id in $GET_INSTANCE_ID; do
        GET_INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids $id --query 'Reservations[*].Instances[*].State.Name' --output text)
        GET_INSTANCE_NAME=$(aws ec2 describe-instances --instance-ids $id --query 'Reservations[*].Instances[*].Tags[*].Value' --output text)
        GET_INSTANCE_PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $id --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
        GET_INSTANCE_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
        echo  "$GET_INSTANCE_NAME -- $id -- $GET_INSTANCE_PUBLIC_IP -- $GET_INSTANCE_STATE"

        if [ "$GET_INSTANCE_NAME" == "minikube" -a "$GET_INSTANCE_STATE" == "stopped" ]; then
                aws ec2 start-instances --instance-ids $id
                echo "$GET_INSTANCE_NAME is started..."
                sleep 20
                GET_INSTANCE_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $id --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)
                echo "$GET_INSTANCE_NAME -- $id -- $GET_INSTANCE_PUBLIC_IP -- $GET_INSTANCE_STATE"
        fi

done