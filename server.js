var http = require('http');
var port = process.env.port || 8080;
http.createServer(function(request, response){
    response.writeHead(200, { 'Content-Type': 'text/plain' });
    response.end('Response from NodeJS Web App'); // we'll be replacing this later
}).listen(port);