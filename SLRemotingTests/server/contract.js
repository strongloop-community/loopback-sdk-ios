// Copyright IBM Corp. 2014,2015. All Rights Reserved.
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
getSecret.http = { path: '/customizedGetSecret', verb: 'GET' };

/**
 * Takes a string and returns an updated string.
 */
function transform(str, callback) {
  callback(null, 'transformed: ' + str);
}
transform.shared = true;
transform.accepts = [{ arg: 'str', type: 'string' }];
transform.returns = [{ arg: 'data', type: 'string' }];
transform.http = { path: '/customizedTransform', verb: 'GET' };

/**
 * Obtains the access token and returns it.
 */
function getAuthorizationHeader(auth, callback) {
  callback(null, auth);
}
getAuthorizationHeader.shared = true;
getAuthorizationHeader.accepts = [{ arg: 'auth', type: 'string', http: function(ctx) {
  return ctx.req.header('authorization');
}}];
getAuthorizationHeader.returns = [{ arg: 'data', type: 'string' }];
getAuthorizationHeader.http = { path: '/get-auth' };

module.exports = {
  getSecret: getSecret,
  transform: transform,
  getAuthorizationHeader: getAuthorizationHeader,
};
