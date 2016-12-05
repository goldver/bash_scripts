#!/bin/bash
# Script to create weekly AMI backups

echo  "----------------------------------\n   `date`   \n----------------------------------"
echo  "This scrip makes a backup"

# backup date
date=`date +%F`
# names of instances to backup
ami_name=("etl" "bi-app" "dw-app" "etl-pp");
# list of instances to backup
instance_ids=('i-6687b682' 'i-d6a3b133' 'i-efa60dad' 'i-a2974108')
# ami description
ami_description="daily-$date"
# backup resolution
backup_resolution="daily"
# 

ami_names_counter=0
for instance_id in ${instance_ids[*]}; do
    aws ec2 create-image --instance-id ${instance_id} --name ${ami_name[$ami_names_counter]}-${backup_resolution}-${date} --description ${ami_description} --no-reboot
    ami_names_counter=${ami_names_counter}+1
done

if [ $? -eq 0 ]; then
        printf "##### Backup complete! #####\n"
fi