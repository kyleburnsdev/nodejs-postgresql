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
else
    echo "No .env file to import"
fi

# File path. The folder "/build/Release" (relative to repo root)
# is included in the .gitignore so that build outputs will not be put in the repo
if [[ -s $DEPLOYMENT_FILE_PATH ]]; 
then
    echo "$DEPLOYMENT_FILE_PATH exists"
else
    echo "$DEPLOYMENT_FILE_PATH missing or is empty"
    exit 1
fi

# 
# build the npm package and zip the deployable application artifacts
# for use in the deployment. The folder "/build/Release" (relative to repo root)
# is included in the .gitignore so that build outputs will not be put in the repo
#
npm install ..
targetFolder = $(dirname "$DEPLOYMENT_FILE_PATH")
mkdir -p $targetFolder
zip -r $DEPLOYMENT_FILE_PATH ../node_modules ../package-lock.json ../package.json ../server.js
