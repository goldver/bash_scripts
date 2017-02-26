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
# parsing to aws table
aws ec2 describe-images --filters Name=name,Values="area-*" --output table # amis area-* all
aws ec2 describe-images --filters Name=name,Values="area-*" --query "Images[*].{imageid:ImageId}" --output table # amis area-* imageids
aws ec2 describe-images --filters Name=name,Values="area-*" --query "Images[*].[ImageId, Name, Tags[*].[Key,Value]]" # tags
aws ec2 describe-images --filters Name=name,Values="area-*" --query "Images[*].[{imageid:ImageId, name:Name, date:CreationDate}, {tags:Tags[*].[{key:Key,value:Value}]}]"

# parsing and descending sort s
image_names="area"

for image_name in ${image_names}; do
    json=$(aws ec2 describe-images --filters Name=name,Values="${image_names}-*"  --query "Images[*].{imageid:ImageId, name:Name, date:CreationDate}") 
	echo $json | jq -r '.[] | .date + "\t" + .imageid + "\t" + .name' | sort -r 
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
ami_count=0

for name in ${names[*]}; do
	echo '**********'
    echo 'Date                            | AMI IDs             | AMI Name          | Tag:Value'
    echo '**********'

	source $HOME/repos/devops-terraform/scripts/configs/"$name".txt

	tag_value='devops_automated'

	echo '### AMI of' ${name} 'service ###'

	json=$(aws ec2 describe-images --filters Name=name,Values="${name}-*" Name=tag-key,Values="${tag_value}" --query "Images[*].[{imageid:ImageId, name:Name, date:CreationDate}, {tags:Tags[*].[{key:Key}, {value:Value}]}]")

    image_ids=$(echo $json | jq '(.[] | .[0] | .date + " " + .imageid + " " + .name )')
	length=`echo $json | jq -r '.[] | .[0] | .imageid ' | wc -l`
	[ $ami_count -ge $length ] && echo "Info: no AMIs to delete." 

	image_ids=$(echo $json | jq -r '(.[] | .[0] | .date + "  " + .imageid + "  " + .name)' | sort | head -n $((length-${ami_count})) | awk '{print $2}')
    echo $json | jq -r '(.[] | .[0] | .date + "\t" + .imageid + "\t" + .name) + "\t" + (.[] | .[1] | .tags | .[][] | .key + "\t" + .value)' | sort | head -n $((length-${ami_count}))

	echo '**********'
	echo 'Next AMIs will be derigester...'
	echo '**********'

	for image_id in $image_ids; do
        echo "Info: deregistering image: $image_id"
        #aws ec2 deregister-image --image-id $image_id
	done  
done
