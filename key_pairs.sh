#!/bin/bash
# chmod +x ./key_all_services.sh

source $HOME/repos/devops-terraform/scripts/configs/scrum-services.txt
my_path="${HOME}/Desktop/deploy_key"
my_mail="devops@gett.com"

rm -rf "${my_path}"

for name in ${names[*]}; do
	source $HOME/repos/devops-terraform/scripts/configs/"$name".txt
	#echo "$name"
	if [ ! -d "${my_path}/${name}" ]; then
		mkdir -p "${my_path}/${name}"
	fi
	ssh-keygen -b 2048 -t rsa -f "${my_path}/${name}/deploy_key" -q -N "" -C "${my_mail}"

	DST="${HOME}/Desktop/deploy_key"

	cd "${my_path}/${name}"
	echo "Service name is: ${name}"
	cd ${DST}/${name}
	cat "deploy_key.pub"  
	echo "##############################################################################"
	sed -e :a -e '$!N;' -e 's/\n/\\n/; ta' deploy_key
	cd ${DST}
done


