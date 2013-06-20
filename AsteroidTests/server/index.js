var asteroid = require('asteroid');
var app = asteroid();
var Memory = asteroid.createDataSource({
  connector: asteroid.Memory
});
var Widget = asteroid.createModel('widget', {
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

app.use(asteroid.rest());
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
