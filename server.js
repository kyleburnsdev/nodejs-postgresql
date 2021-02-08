var http = require('http');
var port = process.env.port || 1337;
http.createServer(function(request, response){
    response.writeHead(200, { 'Content-Type': 'text/plain' });
    response.end({'now':'foo'}); // we'll be replacing this later
}).listen(port);