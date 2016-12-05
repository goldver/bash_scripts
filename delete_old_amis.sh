#!/bin/bash

#jq - parser >> install >> brew install jq
#chmod +x ./delete_old_amis.sh

backup_type="daily"
year="2016"

save_days=1

# lookup next instances
image_names="bi-app etl dw-app etl-pp"

for image_name in $image_names; do
	json=$(aws ec2 describe-images --filters Name=name,Values="${image_name}-${backup_type}-${year}-*-*" --query "Images[*].{imageid:ImageId, name:Name, date:CreationDate}")
    length=`echo $json | jq -r '.[] | .imageid ' | wc -l`
    [ $save_days -ge ${length} ] && echo "Info: no Backups to delete." && exit 1

    image_ids=$(echo $json | jq -r '.[] | .date + "  " + .imageid + "  " + .name' | sort | head -n $((length-${save_days})) | awk '{print $2}')

    for image_id in $image_ids; do
    	echo "Info: deregistering image: ${image_id}"
    	aws ec2 deregister-image --image-id ${image_id}
    done
done

exit 0




