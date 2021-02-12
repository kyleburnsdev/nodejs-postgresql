# nodejs-postgresql

> This project was created for *demonstration purposes only*.
> While concepts may provide the basis for production implementations, it is not intended for any purpose other than demonstration in its current form.

## Overview

This series is meant to help developers implement their first application using a NodeJS webserver and PostgreSQL database all hosted in PaaS services on Microsoft's Azure cloud. It is intentionally simple to reduce distractions. Over time, a progression of "milestones" will be developed to progressively add elements found in production-ready software. These milestones will be represented by long living "snapshot" branches. The planned progression is:
- [x] [Basic NodeJS app](#basic-nodejs-app)
- [x] [Basic database connectivity](#simple-database-connectivity)
- [ ] Key Vault Secrets
- [ ] Private Networking
- Docker

## Set-up
TODO: setup instructions and pre-reqs

## Basic NodeJS app

This is a baseline intended to deploy as simple NodeJS to Azure App Service and verify that the code can execute. The snapshot for this milestone can be found in the `starter-nodeapp` branch.

The NodeJS web server listens and responds to any request with a fixed, plain text response.

```
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
