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

module.exports = SimpleClass;
