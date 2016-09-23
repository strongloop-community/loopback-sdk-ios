// Copyright IBM Corp. 2013,2015. All Rights Reserved.
// Node module: loopback-sdk-ios
// This file is licensed under the MIT License.
// License text available at https://opensource.org/licenses/MIT

var loopback = require('loopback');
var path = require('path');
var app = loopback();

app.dataSource('Memory', { connector: 'memory' });

var Widget = app.registry.createModel('widget',
  {
    name: {
      type: String,
      required: true
    },
    bars: {
      type: Number,
      required: false
    },
    bars2: {
      type: Number,
      required: false
    },
    flag: {
      type: Boolean,
      required: false
    },
    flag2: {
      type: Boolean,
      required: false
    },
    data: {
      type: Object,
      required: false
    },
    stringArray: {
      type: [String],
      required: false
    },
    date: {
      type: Date,
      required: false
    },
    buffer: {
      type: Buffer,
      required: false
    },
    geopoint: {
      type: 'geopoint',
      required: false
    }
  });

app.model(Widget, { dataSource: 'Memory' });

Widget.testDate = function(date, callback) {
  // advance the time of the given date by 1 second and return it
  var ret = new Date(date.getTime() + 1000);
  callback(null, ret);
};
Widget.testDate.shared = true;
Widget.testDate.accepts = [{ arg: 'date', type: 'date' }];
Widget.testDate.returns = [{ arg: 'date', type: 'date' }];
Widget.testDate.http = { verb: 'get' };

Widget.testBuffer = function(buffer, callback) {
  // increment all the bytes of the given buffer by 1 and return it
  for (var i = 0; i < buffer.length; i++) {
    buffer[i]++;
  }
  callback(null, buffer);
};
Widget.testBuffer.shared = true;
Widget.testBuffer.accepts = [{ arg: 'buffer', type: 'buffer' }];
Widget.testBuffer.returns = [{ arg: 'buffer', type: 'buffer' }];
Widget.testBuffer.http = { verb: 'get' };

Widget.testGeoPoint = function(geopoint, callback) {
  // add 1 to both lat and lng of the given geopoint and return it
  geopoint.lat += 1;
  geopoint.lng += 1;
  callback(null, geopoint);
};
Widget.remoteMethod('testGeoPoint', {
  accepts: [{ arg: 'geopoint', type: 'geopoint' }],
  returns: [{ arg: 'geopoint', type: 'geopoint' }],
  http: { verb: 'get', source: 'form'}
});

var lbpn = require('loopback-component-push');
var PushModel = lbpn.createPushModel(app, { dataSource: app.dataSources.Memory });
var Installation = lbpn.Installation;
Installation.attachTo(app.dataSources.Memory);
app.model(Installation);

var ds = app.dataSource('storage', {
  connector: 'loopback-component-storage',
  provider: 'filesystem',
  root: path.join(__dirname, 'storage')
});

var container = loopback.createModel({ name: 'container', base: 'Model' });
app.model(container, { dataSource: 'storage' });

var GeoPoint = require('loopback-datasource-juggler/lib/geo').GeoPoint;

Widget.destroyAll(function () {
  Widget.create({
    name: 'Foo',
    bars: 0,
    data: {
      data1: 1,
      data2: 2
    },
    array: [
      'one',
      'two',
      'three'
    ],
    date: new Date('January 1, 1970 00:00:00.000Z'),
    buffer: new Buffer('010203', 'hex'),
    geopoint: new GeoPoint({lat: 10.32424, lng: 5.84978})
  });
  Widget.create({
    name: 'Bar',
    bars: 1
  });
});

app.model(loopback.AccessToken, {dataSource: 'Memory'});

var Customer = app.registry.createModel('Customer', {},
  {
    base: 'User',
    relations: {
      accessTokens: {
        model: "AccessToken",
        type: "hasMany",
        foreignKey: "userId"
      }
    }
  });

app.model(Customer, { dataSource: 'Memory' });

app.dataSource('mail', { connector: 'mail' });

app.enableAuth({ dataSource: 'Memory' });

app.use(loopback.token({ model: app.models.AccessToken }));
app.use(loopback.rest());
app.listen(3000, function() {
  console.log('https server is ready at https://localhost:3000.');
});
