
#!/bin/bash
# chmod +x ./scrum_role.sh

src="${HOME}/repos/chef_copy"
dst="${HOME}/Desktop/scrum_role/"
scrum_name='scrum9'

# create directory 
if [ ! -d ${dst} ]; then
    mkdir -p ${dst} 
    echo "Your directory: ${dst} has created..."
  else
    echo "Your directory: ${dst} already exists..."
fi

# copy role's files
if [ ! "$(ls -A ${dst})" ]; then
    cp ${src}/roles/*/*${scrum_name}.rb ${dst} 
    echo "Your files were copied to: ${dst}..."
  else
    echo "Your directory: ${dst} isn't empty..."
fi

# set scrum number
echo 'Please enter your scrum number:'
read new_scrum

if [ -z ${new_scrum} ]; then
	echo "The scrum number is invalid!"
exit 1
fi

cd ${dst}

# rename scrum number
for files in *.rb
do
	role_name=$(echo ${files} | cut -d '-' -f1)

	if [ ${role_name} == 'service' ]; then # for service-hub-scrum
		role_name=$(echo ${files} | cut -d '-' -f1-2)
		
	elif [ ${role_name} == 'class' ]; then
		role_name=$(echo ${files} | cut -d '-' -f1-2) # for class-[service]-scrum
	fi	

	sed "s/${scrum_name}/scrum${new_scrum}/g" $files > "${role_name}-scrum${new_scrum}.rb"
	roles_path=`find ${src}/roles -name ${files}`
 	echo "${role_name}-scrum${new_scrum}.rb"
	#mv $files "$role_name-scrum$new_scrum.rb"
	mv "${role_name}-scrum${new_scrum}.rb" $(dirname "${roles_path}")/
done

# remove destination folder after a previous tasks
rm -rf ${dst}













