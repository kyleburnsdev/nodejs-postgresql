# pipeline parameters
appName="nodepostgres2"
environment="poc"
location="eastus"

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
    --parameters appName=$appName environment=$environment

