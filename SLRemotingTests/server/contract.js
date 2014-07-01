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

module.exports = {
  getSecret: getSecret,
  transform: transform
};
