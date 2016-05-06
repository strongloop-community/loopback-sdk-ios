// Copyright IBM Corp. 2014,2015. All Rights Reserved.
// Node module: loopback-sdk-ios
// This file is licensed under the MIT License.
// License text available at https://opensource.org/licenses/MIT

/**
 * A simple class that contains a name.
 */
function SimpleClass(name) {
  this.name = name;
}

/**
 * In order to expose SimpleClass, we need a "shared constructor".
 */
SimpleClass.sharedCtor = function (name, callback) {
  callback(null, new SimpleClass(name));
};
SimpleClass.shared = true;
SimpleClass.sharedCtor.accepts = [{ arg: 'name', type: 'string' }];
SimpleClass.sharedCtor.returns = { type: 'object', root: true };
SimpleClass.sharedCtor.http = { path: '/prototype' };

/**
 * Returns the SimpleClass instance's name.
 */
SimpleClass.prototype.getName = function(callback) {
  callback(null, this.name);
};
SimpleClass.prototype.getName.shared = true;
SimpleClass.prototype.getName.accepts = [];
SimpleClass.prototype.getName.returns = [{ arg: 'data', type: 'string' }];

/**
 * Takes in a name, returning a greeting for that name.
 */
SimpleClass.prototype.greet = function(other, callback) {
  callback(null, 'Hi, ' + other + '!');
};
SimpleClass.prototype.greet.shared = true;
SimpleClass.prototype.greet.accepts = [{ arg: 'other', type: 'string' }];
SimpleClass.prototype.greet.returns = [{ arg: 'data', type: 'string' }];

/**
 * Returns the SimpleClass prototype's favorite person's name.
 */
SimpleClass.getFavoritePerson = function(callback) {
  callback(null, 'You');
};
SimpleClass.getFavoritePerson.shared = true;
SimpleClass.getFavoritePerson.accepts = [];
SimpleClass.getFavoritePerson.returns = [{ arg: 'data', type: 'string' }];

/**
 * Returns a binary sequence.
 */
SimpleClass.binary = function(res) {
  res.type('application/octet-stream');
  res.status(200).send(new Buffer('010203', 'hex'));
};
SimpleClass.binary.shared = true;
SimpleClass.binary.accepts = [{arg: 'res', type: 'object', 'http': {source: 'res'}}];

/**
 * Returns a binary sequence.
 */
SimpleClass.prototype.binary = function(res) {
  res.type('application/octet-stream');
  res.status(200).send(new Buffer('040506', 'hex'));
};
SimpleClass.prototype.binary.shared = true;
SimpleClass.prototype.binary.accepts = [{arg: 'res', type: 'object', 'http': {source: 'res'}}];

module.exports = SimpleClass;
