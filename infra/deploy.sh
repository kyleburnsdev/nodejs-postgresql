#
# THIS SCRIPT WAS CREATED FOR DEMONSTRATION PURPOSES ONLY.
# WHILE CONCEPTS MAY PROVIDE THE BASIS FOR PRODUCTION DEPLOYMENT
# SCRIPTS, IT IS NOT INTENDED FOR ANY PURPOSE OTHER THAN DEMONSTRATION
# IN ITS CURRENT FORM
#

#
# THIS SCRIPT REQUIRES THE MICROSOFT AZURE CLI (http://aka.ms/azcli)
#
az -v

echo "Checking for .env to import"
if [ -f ../.env ]; then
    echo "Importing .env"
    export $(cat ../.env | xargs)
else
    echo "No .env file to import"
fi

echo "Ensuring environment variables set up"
if [ "$APPNAME" = "" ]
then
 1>&2 echo "APPNAME environment variable is not set"
 exit 1
fi

if [ "$ENVIRONMENT" = "" ]
then
 1>&2 echo "ENVIRONMENT environment variable is not set"
 exit 1
fi

if [ "$LOCATION" = "" ]
then
 1>&2 echo "LOCATION environment variable is not set"
 exit 1
fi

if [ "$DBUSER" = "" ]
then
 1>&2 echo "DBUSER environment variable is not set"
 exit 1
fi
#dbPassword
if [ "$dbPassword" = "" ]
then
 1>&2 echo "dbPassword environment variable is not set"
 exit 1
fi

appName=$APPNAME
environment=$ENVIRONMENT
location=$LOCATION
dbUser=$DBUSER

# print non-sensitive variables (not the password)
echo $appName
echo $environment
echo $location
echo $dbUser
echo $DEPLOYMENT_FILE_PATH

# derived
resourceGroupName="$appName-$environment-$location-rg"
isUpdate=$(az group exists -n $resourceGroupName)

if [ "$isUpdate" = "false" ]
then
echo "New Deployment. Creating Resource Group..."
az group create -l $location -n $resourceGroupName
fi

echo "Applying Template"
az deployment group create -g $resourceGroupName \
    --template-file azureDeploy.json \
    --parameters appName=$appName environment=$environment \
    --parameters dbUser=$dbUser dbPassword=$dbPassword

# THE FIREWALL RULE COULD BE INCLUDED IN THE TEMPLATE, BUT WE WILL BE REMOVING LATER
# SO I AM SCRIPTING IT TO DRAW ATTENTION TO THE NEED FOR FIREWALL RULES IN SUPPORT
# OF *ANY* NEEDED CONNECTIVITY
echo "Setting up Allow Azure Firewall Rule"
az postgres server firewall-rule create --resource-group $resourceGroupName --server-name $appName-$environment-$location-psql --name AllowAllAzureIps --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

echo "Deploying Website"
az webapp deployment source config-zip --resource-group $resourceGroupName --name $appName-$environment-$location-app --src $DEPLOYMENT_FILE_PATH

echo "Deployment complete"
