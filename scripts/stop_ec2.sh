#!/bin/bash

GET_INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=instance-state-name, Values=running" --query Reservations[*].Instances[*].InstanceId --output text)

for id in $GET_INSTANCE_ID; do 
        aws ec2 stop-instances --instance-ids $id
        echo "Instance $id is stopped"
done