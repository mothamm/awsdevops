#!/bin/bash
echo -e "Enter the number of Volumes you want to create: \c" ; read input
echo "Entered value is $input. Number of volumes will be created: $input"
i=1
while [ $i -le $input ]
do
    echo -e "Creating EBS volume with Size ${i}GB..."
    aws ec2 create-volume --volume-type gp2 --size ${i} --availability-zone us-east-1a
    let i=$i+1
done
echo "Create "