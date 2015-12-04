## Creating Your Own LBModel: Subclassing

### Prerequisites

 - **Knowledge of Objective-C and iOS App Development**
 - **LoopBack iOS SDK** - You should know how to set this up already if you've
    gone through the [Getting Started](#getting-started). If not, run through
    that guide first. It doesn't take long, and it provides the basis for this
    guide.
 - **Schema** - Explaining the type of data to store and why is outside the
    scope of this guide, being tightly coupled to your application's needs.

### Summary

Creating a subclass of LBModel allows you to profit from all the benefits of an
Objective-C class (e.g. compile-time type checking) within your LoopBack data
types.

### Step 1: Model Interface & Properties

As with any Objective-C class, the first step is to build your interface. If we
leave any [custom behaviour](#http://docs.strongloop.com/strong-remoting) for
later, then it's just a few `@property` declarations and we're ready for the
implementation.

```objectivec
/**
 * A widget for sale.
 */
@interface Widget : LBModel // This is a subclass, after all.

// Being for sale, each widget has a way to be identified and an amount of
// currency to be exchanged for it. Identifying the currency to be exchanged is
// left as an uninteresting exercise for any financial programmers reading this.
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSNumber *price;

@end
```

### Step 2: Model Implementation

Since we've left [custom behaviour](#http://docs.strongloop.com/strong-remoting)
for later, then I'll just leave this here.

```objectivec
@implementation Widget
@end
```

### Step 3: Repository Interface

The `LBModelRepository` is the LoopBack iOS SDK's placeholder for what in Node is
a JavaScript prototype representing a specific "type" of Model on the server. In
our example, this would be the model exposed as "widget" (or similar) on the
server:

```javascript
var Widget = loopback.createModel('widget', {
  name: String,
  price: Number
});
```

Because of this the Prototype name (`'widget'`, above) needs to match the name
that model was given on the server. _If you don't have a model, [see this
guide](#) for more information._ The model _must_ exist (even if the schema is
empty) before it can be interacted with.

**TL;DR** - Use this to make creating Models easier. Match the name or create
your own.

Since `LBModelRepository` provides a basic implementation, we only need to
override its constructor to provide the appropriate name.

```objectivec
@interface WidgetRepository : LBModelRepository

+ (instancetype)repository;

@end
```

### Step 4: Repository Implementation

Remember to use the right name:

```objectivec
@implementation WidgetRepository

+ (instancetype)repository {
    return [self repositoryWithClassName:@"widget"];
}

@end
```

### Step 5: A Little Glue

Just as we did in [the getting started guide](#getting-started), we'll need an
`LBRESTAdapter` instance to connect to our server:

```objectivec
LBRESTAdapter *adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://myserver:3000"]];
```

**Remember:** Replace `"http://myserver:3000"` with the complete URL to your
server.

Once we have that adapter, we can create our Repository instance.

```objectivec
WidgetRepository *repository = (WidgetRepository *)[adapter repositoryWithModelClass:[WidgetPrototype class]];
```

### Step 6: Profit!

Now that we have a `WidgetRepository` instance, we can:

 - Create a `Widget`

```objectivec
Widget *pencil = (Widget *)[repository modelWithDictionary:@{ @"name": @"Pencil", @"price": @1.50 }];
```

 - Save said `Widget`

```objectivec
[pencil saveWithSuccess:^{
                    // Pencil now exists on the server!
                }
                failure:^(NSError *error) {
                    NSLog("An error occurred: %@", error);
                }];
```

 - Find another `Widget`

```objectivec
[repository findById:@2
              success:^(LBModel *model) {
                  Widget *pen = (Widget *)model;
              }
              failure:^(NSError *error) {
                  NSLog("An error occurred: %@", error);
              }];
```

 - Remove a `Widget`

```objectivec
[pencil destroyWithSuccess:^{
                       // No more pencil. Long live Pen!
                   }
                   failure:^(NSError *error) {
                       NSLog("An error occurred: %@", error);
                   }];
```
