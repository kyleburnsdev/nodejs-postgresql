#!/bin/bash
#
# THIS SCRIPT WAS CREATED FOR DEMONSTRATION PURPOSES ONLY.
# WHILE CONCEPTS MAY PROVIDE THE BASIS FOR PRODUCTION DEPLOYMENT
# SCRIPTS, IT IS NOT INTENDED FOR ANY PURPOSE OTHER THAN DEMONSTRATION
# IN ITS CURRENT FORM
#

# (see deploy.sh for explanation)
echo "Checking for .env to import"
if [ -f ../.env ]; then
    echo "Importing .env"
    export $(cat ../.env | xargs)
    # above broke on Darwin
    eval $(grep -v -e '^#' ../.env | xargs -I {} echo export \'{}\')
else
    echo "No .env file to import"
fi

# File path. The folder "/build/Release" (relative to repo root)
# is included in the .gitignore so that build outputs will not be put in the repo
if [[ "$DEPLOYMENT_FILE_PATH" = "" ]]; 
then
    echo "DEPLOYMENT_FILE_PATH variable missing"
    exit 1
else
    echo "$DEPLOYMENT_FILE_PATH exists"
fi

# 
# build the npm package and zip the deployable application artifacts
# for use in the deployment. The folder "/build/Release" (relative to repo root)
# is included in the .gitignore so that build outputs will not be put in the repo
#
npm install ..
targetFolder=$(dirname "$DEPLOYMENT_FILE_PATH")
echo "target folder is $targetFolder"
mkdir -p $targetFolder
zip -r $DEPLOYMENT_FILE_PATH ../node_modules ../package-lock.json ../package.json ../server.js
