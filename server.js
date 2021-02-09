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