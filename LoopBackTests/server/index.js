var loopback = require('loopback');
var path = require('path');
var app = loopback();
app.set('legacyExplorer', false);
app.use(loopback.logger(app.get('env') === 'development' ? 'dev' : 'default'));
app.dataSource('Memory', {
  connector: loopback.Memory,
  defaultForType: 'db'
});

var Widget = app.model('widget', {
  properties: {
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
    date: {
      type: Date,
      required: false
    },
    data: {
      type: Object,
      required: false
    }
  },
  dataSource: 'Memory'
});

var lbpn = require('loopback-component-push');
var PushModel = lbpn.createPushModel(app, { dataSource: app.dataSources.Memory });
var Installation = lbpn.Installation;
Installation.attachTo(app.dataSources.Memory);
app.model(Installation);

var ds = loopback.createDataSource({
  connector: require('loopback-component-storage'),
  provider: 'filesystem',
  root: path.join(__dirname, 'storage')
});

var container = ds.createModel('container');

app.model(container);

Widget.destroyAll(function () {
  Widget.create({
    name: 'Foo',
    bars: 0,
    data: {
      quux: true
    }
  });
  Widget.create({
    name: 'Bar',
    bars: 1,
    date: '2000-01-02T03:04:05.006Z'
  });
});

app.model(loopback.AccessToken);

app.model('Customer', {
  options: {
    base: 'User',
    relations: {
      accessTokens: {
        model: "AccessToken",
        type: "hasMany",
        foreignKey: "userId"
      }
    }
  },
  dataSource: 'Memory'
});

app.dataSource('mail', { connector: 'mail', defaultForType: 'mail' });
loopback.autoAttach();

app.enableAuth();
app.use(loopback.token({ model: app.models.AccessToken }));
app.use(loopback.rest());
app.listen(3000, function() {
  console.log('https server is ready at https://localhost:3000.');
});
