# parse command parameters
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

# pipeline parameters
echo $appName
echo $environment
echo $location
echo $dbUser
echo $dbPassword

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


