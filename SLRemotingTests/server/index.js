// Copyright IBM Corp. 2014,2015. All Rights Reserved.
// Node module: loopback-sdk-ios
// This file is licensed under the MIT License.
// License text available at https://opensource.org/licenses/MIT

var express = require('strong-remoting/node_modules/express');
var app = express();
var remotes = require('strong-remoting').create();

remotes.exports = {
  simple: require('./simple'),
  contract: require('./contract'),
  SimpleClass: require('./simple-class'),
  ContractClass: require('./contract-class'),
  nonroot: require('./nonroot')
};

app.use(remotes.handler('rest'));

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

