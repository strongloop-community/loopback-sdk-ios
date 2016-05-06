// Copyright IBM Corp. 2014. All Rights Reserved.
// Node module: loopback-sdk-ios
// This file is licensed under the MIT License.
// License text available at https://opensource.org/licenses/MIT

/**
 * A simple class that contains a name, this time with a custom HTTP contract.
 */
function ContractClass(name) {
  this.name = name;
}

/**
 * In order to expose ContractClass, we need a "shared constructor".
 */
ContractClass.sharedCtor = function (name, callback) {
  callback(null, new ContractClass(name));
};
ContractClass.shared = true;
ContractClass.sharedCtor.accepts = [{ arg: 'name', type: 'string' }];
ContractClass.sharedCtor.http = { path: '/:name' };
ContractClass.sharedCtor.returns = { type: 'object', root: true };

/**
 * Returns the ContractClass instance's name.
 */
ContractClass.prototype.getName = function(callback) {
  callback(null, this.name);
};
ContractClass.prototype.getName.shared = true;
ContractClass.prototype.getName.accepts = [];
ContractClass.prototype.getName.returns = [{ arg: 'data', type: 'string' }];

/**
 * Takes in a name, returning a greeting for that name.
 */
ContractClass.prototype.greet = function(other, callback) {
  callback(null, 'Hi, ' + other + '!');
};
ContractClass.prototype.greet.shared = true;
ContractClass.prototype.greet.accepts = [{ arg: 'other', type: 'string' }];
ContractClass.prototype.greet.returns = [{ arg: 'data', type: 'string' }];

/**
 * Returns the ContractClass prototype's favorite person's name.
 */
ContractClass.getFavoritePerson = function(callback) {
  callback(null, 'You');
};
ContractClass.getFavoritePerson.shared = true;
ContractClass.getFavoritePerson.accepts = [];
ContractClass.getFavoritePerson.returns = [{ arg: 'data', type: 'string' }];

module.exports = ContractClass;
