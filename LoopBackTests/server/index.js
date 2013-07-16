var loopback = require('loopback');
var app = loopback();
var Memory = loopback.createDataSource({
  connector: loopback.Memory
});
var Widget = loopback.createModel('widget', {
  name: {
    type: String,
    required: true
  },
  bars: {
    type: Number,
    required: false
  },
  data: {
    type: Object,
    required: false
  }
});

Widget.attachTo(Memory);
app.model(Widget);

app.use(loopback.rest());
app.listen(3000);

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
    bars: 1
  });
});
