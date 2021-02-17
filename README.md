# nodejs-postgresql

> This project was created for *demonstration purposes only*.
> While concepts may provide the basis for production implementations, it is not intended for any purpose other than demonstration in its current form.

## Overview

This series is meant to help developers implement their first application using a NodeJS webserver and PostgreSQL database all hosted in PaaS services on Microsoft's Azure cloud. It is intentionally simple to reduce distractions. Over time, a progression of "milestones" will be developed to progressively add elements found in production-ready software. These milestones will be represented by long living "snapshot" branches. The planned progression is:
- [x] [Basic NodeJS app](#basic-nodejs-app)
- [x] [Basic database connectivity](#simple-database-connectivity)
- [X] [Key Vault Secrets](#key-vault-secrets)
- [ ] Private Networking
- [ ] Docker

## Set-up
The `.env` file in the repository root is intended to remain excluded from source control and used to control environment variables that will be used to build and deploy the application as well as support running the application from your local development machine. You will need to update with your own values.

- These variables are used by build and deploy scripts
  - `APPNAME` - a unique name for your application (e.g. "mynodepsql"). Because the deployment will provision resources with public URLs, the combination of `APPNAME`, `ENVIRONMENT`, and `LOCATION` most be globally unique
  - `ENVIRONMENT` - a designator for the environment that you are deploying into (e.g. `dev`, `stage`, `prod`, etc). This value is only important to *you* semantically, so for the sake of this example, you may choose to embed your initials and date to help with uniqueness
  - `LOCATION` - The Azure region which will be used for provisioning all resources. For a list of available regions, you can run `az account list-locations -o table`. Use the value from the `name` column of one of the regions to populate this variable
  - `DBUSER` - the username that will be used for the default administrative user in the Azure Database for PostreSQL instance. The platform will prevent use of well known usernames that are often created for "super users" as a security precaution, so pick something unique
  - `dbPassword` - the password that will be used for the administrative user. Password complexity requirements apply, so be sure to use a password of 8-16 characters with a combination of at least three of the following:
    - Uppercase alpha
    - Lowercase alpha
    - Number
    - Special character
  - `DEPLOYMENT_FILE_PATH` - this is a path to the zip file that the build script will create and the deployment script will deploy. In the sample `.env` file, a path under the `build` directory is specified because that path is excluded from source control in the `.gitignore` and you do not want to check in build outputs.
- These variables are used by the NodeJS application itself when running locally
  - `PGHOST` - the fully qualified host name of the PostgreSQL instance running in Azure. This can be viewed on the Overview blade for the Azure Database for PostgreSQL instance in the Azure portal and is in the format `<database_hostname>.postres.database.azure.com` (database host name is derived from build and deploy variables above)
  - `PGUSER` - the fully qualified username for the user account used to log into the database. This is in the format `<DBUSER>@<database_hostname>`
  - `PGDATABASE` - the name of the database on the server. In the case of this example, we are using the default `postgres` database that is installed when you provision Azure Database for PostgreSQL
  - `PGPASSWORD` - the password specified above in the build and deploy variables

> NOTE: The build and deployment scripts were developed for environments that support bash. They were developed and tested in a Ubuntu Linux environment and in the [Windows Subsystem for Linux (WSL2)](http://aka.ms/wsl) running Ubuntu

Building the application can be done by running the following commands from a bash shell with `<repo_root>/infra` as your working directory:

```console
chmod +x build.sh
./build.sh
```

Before attempting to deploy the application, be sure that you have used the Azure CLI to log into an Azure subscription where you have permissions to create resource groups and resources. The `az account show` command can be used to verify you are logged in. Use the `az login` command if you are not logged in.

Provisioning of resources and deployment of the application can be accomplished by running the following commands from a bash shell with `<repo_root>/infra` as your working directory:

```console
chmod +x deploy.sh
./deploy.sh
```
The deploy script outputs the URL of the provisioned website on completion, which can be used to view your deployed application.

## Basic NodeJS app

This is a baseline intended to deploy as simple NodeJS to Azure App Service and verify that the code can execute. The snapshot for this milestone can be found in the `starter-nodeapp` branch.

The NodeJS web server listens and responds to any request with a fixed, plain text response.

```javascript
var http = require('http');
var port = process.env.port || 8080;
http.createServer(function(request, response){
    response.writeHead(200, { 'Content-Type': 'text/plain' });
    response.end('Response from NodeJS Web App'); // we'll be replacing this later
}).listen(port);
```
The `infra` folder contains an Azure Resource Manager (ARM) template that defines infrastructure components and can be deployed using the supplied scripts.

## Simple database connectivity

This demonstrates basic connectivity between Azure App Service and Azure Database for PostgreSQL. The snapshot for this milestone can be found in the `basic-db-connection` branch.

In this code, we extend the code by using the `pg` NPM package, which provides for interaction with PostgreSQL databases. The most complex piece of the code is that we cannot use the default parameterless construction behavior of the `Client` and `Pool` objects which reads all connection information from environment variables and instead must create our own params that includes this information *and* specifies that an SSL connection should be used. Once connected, a query (`SELECT NOW()`) is executed to return the current system date/time on the database server and the resulting dataset is turned into a JSON object to be sent to the requestor.

```javascript
const pg = require('pg');

const params = {
    host: process.env.PGHOST,
    user: process.env.PGUSER,
    database: process.env.PGDATABASE,
    ssl: true
};

const queryText = "SELECT NOW()";

var http = require('http');
require('dotenv').config();
var port = process.env.port || 8080;
http.createServer(function(request, response){
    console.log('http request received');
    var client = new pg.Client(params);
    client.connect();
    client.query(queryText, (err, result) => {
        if(err) {
            console.error(err);
            response.writeHead(500, 'Server Error');
            response.end('There was an error processing your request - ' + process.env.PGHOST);
        }
        else {
            response.writeHead(200, {'Content-Type': 'application/json'});
            response.end(JSON.stringify(result.rows));
        }
    });
}).listen(port);
```

## Key Vault Secrets

This expands upon the previous example by more securely storing the database password as a "secret" in [Azure Key Vault](https://docs.microsoft.com/en-us/azure/key-vault/). 

In order to support integration with Azure Key Vault, the web app has been updated to use a System Assigned [Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview). System Assigned Managed Identity can be established by including an "identity" property in the JSON description of the website resource as follows:

```json
//snip
    "type": "Microsoft.Web/sites",
    "kind": "app,linux",
    "name": "[variables('webAppName')]",
    "apiVersion": "2018-11-01",            
    "location": "[parameters('location')]",
    "identity": {
        "type": "SystemAssigned"
    },
//snip
```

The ARM template used to deploy the previous sections has been updated to include provisioning an Azure Key Vault resource. The Key Vault resource declares a dependency in the web app because it will include an access rule allowing the web app to retrieve secret values from the Key Vault. There is no need for the web app to list the keys present in the Key Vault or access any certificates stored in the Key Vault, so the Access Policy is defined without permission to do these things. Here is an example of how the Key Vault is created along with the Access Policy:

```json
//snip
    {
        "type": "Microsoft.KeyVault/vaults",
        "apiVersion": "2016-10-01",
        "name": "[variables('keyVaultName')]",
        "location": "[parameters('location')]",
        "properties": {
            "sku": {
                "name": "standard",
                "family": "A"
            },
            "tenantId": "[subscription().tenantId]",
            "accessPolicies": [
                {
                    "tenantId": "[subscription().tenantid]",
                    "objectId": "[reference(resourceId('Microsoft.Web/sites', variables('webAppName')),'2019-08-01', 'full').identity.principalId]",
                    "permissions": {
                        "keys": [],
                        "secrets": [
                        "get"
                        ],
                    "certificates": []
                }
            }
            ]
        },
        "dependsOn": [
            "[resourceId('Microsoft.Web/sites', variables('webAppName'))]"
        ]
    }
//snip
```

The secret itself is defined as an additional resource and uses the value provided in the `dbPassword` template parameter:

```json
// snip
    {
        "type": "Microsoft.KeyVault/vaults/secrets",
        "apiVersion": "2016-10-01",
        "name": "[variables('keyVaultDbPasswordSecretName')]",
        "location": "[parameters('location')]",
        "dependsOn": [
            "[resourceId('Microsoft.KeyVault/vaults', variables('keyVaultName'))]"
        ],
        "properties": {
            "value": "[parameters('dbPassword')]"
        }
    }
// snip
```

With the foundation set, we can turn our attention to referencing the secret in the web app configuration. The database password setting had previously been stored using

```json
{
    "name": "PGPASSWORD",
    "value": "[variables('dbConnectionAppSettings').password]"
}
```

Now that we are storing the secret in Key Vault, instead the value itself we will make use of a special "macro" [syntax](https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references#reference-syntax) for app settings that instructs app service to retrieve the value from Key Vault in the form `@Microsoft.KeyVault({referenceString})`. The updated definition for this setting is

```json
{
    "name": "PGPASSWORD",
    "value": "[concat('@Microsoft.KeyVault(VaultName=', variables('keyVaultName'), ';SecretName=dbPassword)')]"
}
```