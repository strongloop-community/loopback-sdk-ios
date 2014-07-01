var remotes = require('strong-remoting').create();

remotes.exports = {
  simple: require('./simple'),
  contract: require('./contract'),
  SimpleClass: require('./simple-class'),
  ContractClass: require('./contract-class'),
  nonroot: require('./nonroot')
};

var app = remotes.handler('rest');

var server = require('http')
  .createServer(app)
  .listen(3001, function() {
    console.log('http server is ready at http://localhost:3001.');
  });

var sslConfig = require('./ssl-config');
var options = {
      key: sslConfig.privateKey,
      cert: sslConfig.certificate
    };
var httpsServer = require('https')
  .createServer(options, app)
  .listen(3002, function() {
    console.log('https server is ready at https://localhost:3002.');
  });

