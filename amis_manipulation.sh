# from json file
json=$(cat $HOME/Desktop/myjson.json)

length=`echo $json | jq -r '.[] | .imageid ' | wc -l`
echo $json | jq -r '.[] | .date + "\t" + .imageid + "\t" + .name ' | sort | awk '{print $2}'
#########################
# all amis from aws
json=$(aws ec2 describe-images --query "Images[*].{imageid:ImageId, name:Name, date:CreationDate}")
#########################
# specific amis from aws
image_names="area"

for image_name in ${image_names}; do
    echo json=$(aws ec2 describe-images --filters Name=name,Values="${image_names}-*" --query "Images[*].{imageid:ImageId, name:Name, date:CreationDate}")
done
#########################
# to count amis
image_names="area"

for image_name in ${image_names}; do
    json=$(aws ec2 describe-images --filters Name=name,Values="${image_names}-*" --query "Images[*].{imageid:ImageId, name:Name, date:CreationDate}")
	echo length=`echo $json | jq -r '.[] | .imageid ' | wc -l`
done
##########################
# parsing and descending sort 
image_names="area"

for image_name in ${image_names}; do
    json=$(aws ec2 describe-images --filters Name=name,Values="${image_names}-*" --query "Images[*].{imageid:ImageId, name:Name, date:CreationDate}")
	echo $json | jq -r '.[] | .date + "\t" + .imageid + "\t" + .name ' | sort -r 
done

##########################
# print values from specific file
source $HOME/repos/devops-terraform/scripts/configs/scrum-services.txt

for name in ${names[*]}; do
	source $HOME/repos/devops-terraform/scripts/configs/"$name".txt
	echo 'AMI of' ${name} 'service'
done

##########################
# this script will find matching values and print amis to deregister
#!/bin/bash

source $HOME/repos/devops-terraform/scripts/configs/scrum-services.txt
ami_count=3 # to hold number of latest images 

for name in ${names[*]}; do
	echo '**********'
    echo 'Date                    | AMI IDs        | AMI Name'
    echo '**********'

	source $HOME/repos/devops-terraform/scripts/configs/"$name".txt
	echo '### AMI of' ${name} 'service ###'
	image_names=${name}

	for image_name in ${image_names}; do
	    json=$(aws ec2 describe-images --filters Name=name,Values="${image_names}-*" --query "Images[*].{imageid:ImageId, name:Name, date:CreationDate}")
		length=`echo $json | jq -r '.[] | .imageid ' | wc -l`
		[ $ami_count -ge $length ] && echo "Info: no AMIs to delete." 

		image_ids=$(echo $json | jq -r '.[] | .date + "  " + .imageid + "  " + .name' | sort | head -n $((length-${ami_count})) | awk '{print $2}')
		echo $json | jq -r '.[] | .date + "\t" + .imageid + "\t" + .name ' | sort | head -n $((length-${ami_count}))

		echo '**********'
    	echo 'Next AMIs will be derigester...'
    	echo '**********'

		for image_id in $image_ids; do
	        echo "Info: deregistering image: $image_id"
	        #aws ec2 deregister-image --image-id $image_id
    	done  
	done
done
