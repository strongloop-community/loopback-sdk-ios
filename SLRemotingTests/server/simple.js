// Copyright IBM Corp. 2014. All Rights Reserved.
// Node module: loopback-sdk-ios
// This file is licensed under the MIT License.
// License text available at https://opensource.org/licenses/MIT

/**
 * Returns a secret message.
 */
function getSecret(callback) {
  callback(null, 'shhh!');
}
getSecret.shared = true;
getSecret.accepts = [];
getSecret.returns = [{ arg: 'data', type: 'string' }];

/**
 * Takes a string and returns an updated string.
 */
function transform(str, callback) {
  callback(null, 'transformed: ' + str);
}
transform.shared = true;
transform.accepts = [{ arg: 'str', type: 'string' }];
transform.returns = [{ arg: 'data', type: 'string' }];

module.exports = {
  getSecret: getSecret,
  transform: transform
};
