/**
 * Returns a secret message.
 */
function getMsg(callback) {
  callback(null, 'Hello');
}
getMsg.shared = true;
getMsg.accepts = [];
getMsg.returns = [{ arg: 'data', type: 'string' }];
getMsg.http = {path: '/api/getMsg'};

/**
 * Takes a string and returns an updated string.
 */
function convertMsg(str, callback) {
  callback(null, 'CONVERTED: ' + str.toUpperCase());
}
convertMsg.shared = true;
convertMsg.accepts = [{ arg: 'str', type: 'string' }];
convertMsg.returns = [{ arg: 'data', type: 'string' }];
convertMsg.http = {path: '/api/convertMsg'};

module.exports = {
  getMsg: getMsg,
  convertMsg: convertMsg
};
