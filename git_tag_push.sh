#!/bin/bash
REPO_NAME=(
            "bash_scripts"
            "docker_test"
            "npm_install"
            "web_app"
            "build-script-py"
            "terraform_script"
            "echo"
            "my_configuration"
            "chef-win-environment"
            "adobe-reader"
            "notepad-pp"
            "msoffice"
            "camtasia"
            "oracle-vm"
            "text_file"
            "tcc-le"
            "vmware-player"
            "cygwin-configuration"
            "slik-svn"
            "active-python"
            "active-perl"
            "innosetup-script"
            "multidesc"
           );

ACCOUNT="goldver"
BRANCH="master"
DST="${HOME}/tmp_repos"
TAG="tag_1"

#cd ~ >> for jenkins

if [ ! -d ${DST} ]; then
  	mkdir -p ${DST}
fi

cd ${DST}

# git clone
for REPO in ${REPO_NAME[*]}; do
    echo "#############################################################################"
    echo "Repository name is: ${REPO}"
    git clone -b $BRANCH git@github.com:${ACCOUNT}/${REPO}
    cd ${DST}/${REPO}
    git tag -am ${REPO} -f ${TAG}; git push -u origin ${TAG}
    cd .. 
done 

# git tag per repository
# for REPO in ${REPO_NAME[*]}; do
#     cd ${DST}/${REPO}
#     git tag -am ${REPO} -f ${TAG}; git push -u origin ${TAG}
# done

# remove tmp dir
#rm -rf ${DST}
