# Hello!


## Required Tools

Then install the needed packages:

    # install garuda
    pip install git+https://github.com/nuagenetworks/garuda.git

    # install monolithe
    pip install git+https://github.com/nuagenetworks/monolithe.git

    # install redis and mongodb
    brew install redis mongodb


## Server

### Start Redis and MongoDB

Open a two new tabs in a new terminal.

In the first tab type:

    redis-server

In the second tab, type:

    mongod --config /usr/local/etc/mongod.conf


### Generate your Specifications for the Server

> All this tutorial assumes you'll be working on the provided Specifications.

Generate a SDK from the specifications put it at the expected place:

    monogen -f Specifications
    mv codegen/python/tdldk ./Server

Now you should be able to start the server:

    ./Server/server
    (nukit)(master)StarterKit % ./Server/server

                        1y9~
              .,:---,      "9"R            Garuda 1.0
          ,N"`    ,jyjjRN,   `n ?          ==========
        #^   y&T        `"hQ   y 'y
      (L  ;R@l                 ^a \w       PID: 48653
     (   #^4                    Q  @
     Q  # ,W                    W  ]V      1 channel           : rest.falcon
    |# @L Q                    W   Q|      1 sdk               : tdldk.v1_0
     V @  Vp                  ;   #^[      1 storage plugin    : mongodb
     ^.R[ 'Q@               ,4  .& ,T      1 auth plugin       : simple
      (QQ  'Q4p           (R  ,BL (T       1 permission plugin : owner_permissions
        hQ   H,`"QQQL}Q"`,;&RR   x
          "g   YQ,    ```     :F`          0 logic plugin
            "E,  `"B@MD&DR@B`
                '"N***xD"```


    [INFO] garuda.controller.channels: Forking communication channels...
    [INFO] garuda.controller.channels: Channel garuda.communicationchannels.rest.falcon forked with pid: 48655
    [INFO] garuda.controller.channels: All channels successfully forked
    [INFO] garuda: Garuda is up and ready to rock! (press CTRL-C to exit)
    [INFO] garuda.comm.rest: Listening to inbound connection on 0.0.0.0:3000
    [INFO] garuda.comm.rest: Starting gunicorn with 17 workers

This server won't provide any business logic. However, all CRUD operations, Push Notifications, Simple Permissions Management and so on will be working out of the box.

Incredibly easy, huh?


## Client

### Generate your Specifications for the Client

Now we have a ready to use backend, let's work on the client. The first thing to do is to generate the model from the Specifications using Monolithe and put them in the model directory of the client:

    monogen -f Specifications -L objj
    cp -a codegen/objj/* Client/Models


### Initialize the Client

Go into the `Client` folder:

    cd Client

Add the needed submodules:

    git init .
    git submodule add https://github.com/Cappuccino/Cappuccino.git Libraries/Cappuccino
    git submodule add https://github.com/ArchipelProject/TNKit.git Libraries/TNKit
    git submodule add https://github.com/nuagenetworks/objj-bambou.git Libraries/Bambou
    git submodule add https://github.com/nuagenetworks/NUKit.git Libraries/NUKit

Retrieve Capp Env, if you don't have it:

    curl -L https://raw.githubusercontent.com/cappuccino/cappuccino/master/Tools/capp_env/capp_env > /usr/local/bin/capp_env && chmod u+x /usr/local/bin/capp_env

> This is not mandatory, but highly encouraged

Create a new Cappuccino environment and activate it:

    capp_env -p .cappenvs/master
    source .cappenvs/master/bin/activate

Then build the correct version of Cappuccino:

    cd Libraries/Cappuccino
    jake install
    cd -

Finally, build the libraries:

    ./buildApp -Lv

You are ready to code now!

### What do we want to do?

The goal of this projet is to build a simple multi user ToDo list application. We want to be able to:

- login
- create some todo lists
- create some tasks in the todo list
- create users
- associate users to some tasks.

This is what is described in the Specifications, and this is what our server provides. We will need to create multiple things here:

- One DataView for the Todo list
- One DataView for the Task
- One DataView for the User
- One NUModule for the Todo Lists
- One NUModule for the Tasks
- One NUModule for the Users

We'll be starting working on the DataViews.

### Create the DataViews

In NUKit, DataViews must be set as outlet of a children class of `NUAbstractDataViewsLoader`. The starter kit provides one default loader, available in `DataViews/DataViewsLoader.j`. You can have multiple DataViews Loader, and each of them will be responsible to load the DataViews contained in one single xib file.

Modify the `DataViews/DataViewsLoader.j` and make it look like:

```objj
@import <Foundation/Foundation.j>
@import <NUKit/NUAbstractDataViewsLoader.j>

@import "DataViews.j"


@implementation DataViewsLoader : NUAbstractDataViewsLoader
{
    @outlet SKListDataView listDataView @accessors(readonly);
    @outlet SKTaskDataView taskDataView @accessors(readonly);
    @outlet SKUserDataView userDataView @accessors(readonly);
}

@end
```

Modify the `DataViews/DataViews.j` and make it look like:

```objj
@import "SKListDataView.j"
@import "SKTaskDataView.j"
@import "SKUserDataView.j"
```

Create a file `DataViews/SKListDataView.j` and make it look like:

```objj
@import <Foundation/Foundation.j>
@import <NUKit/NUAbstractDataView.j>

@implementation SKListDataView : NUAbstractDataView
{
    @outlet CPTextField fieldDescription;
    @outlet CPTextField fieldTitle;
}

- (void)bindDataView
{
    [super bindDataView];

    [fieldDescription bind:CPValueBinding toObject:_objectValue withKeyPath:@"description" options:nil];
    [fieldTitle bind:CPValueBinding toObject:_objectValue withKeyPath:@"title" options:nil];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldDescription = [aCoder decodeObjectForKey:@"fieldDescription"];
        fieldTitle = [aCoder decodeObjectForKey:@"fieldTitle"];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldDescription forKey:@"fieldDescription"];
    [aCoder encodeObject:fieldTitle forKey:@"fieldTitle"];
}

@end
```

Create a file `DataViews/SKTaskDataView.j` and make it look like:

```objj
@import <Foundation/Foundation.j>
@import <NUKit/NUAbstractDataView.j>

@implementation SKTaskDataView : NUAbstractDataView
{
    @outlet CPTextField fieldDescription;
    @outlet CPTextField fieldTitle;
    @outlet CPImageView imageStatus;
}

- (void)bindDataView
{
    [super bindDataView];

    [fieldDescription bind:CPValueBinding toObject:_objectValue withKeyPath:@"description" options:nil];
    [fieldTitle bind:CPValueBinding toObject:_objectValue withKeyPath:@"title" options:nil];

    // [imageStatus bind:CPValueBinding toObject:_objectValue withKeyPath:@"status" options:nil];
    // `status` is enumeration in the specification, just for the sake of the example.
    // We'll come back here and show how to used a transformer.
}

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldDescription = [aCoder decodeObjectForKey:@"fieldDescription"];
        fieldTitle = [aCoder decodeObjectForKey:@"fieldTitle"];
        imageStatus = [aCoder decodeObjectForKey:@"imageStatus"];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldDescription forKey:@"fieldDescription"];
    [aCoder encodeObject:fieldTitle forKey:@"fieldTitle"];
    [aCoder encodeObject:imageStatus forKey:@"imageStatus"];
}

@end
```

Create a file `DataViews/SKUserDataView.j` and make it look like:

```objj
@import <Foundation/Foundation.j>
@import <NUKit/NUAbstractDataView.j>

@implementation SKUserDataView : NUAbstractDataView
{
    @outlet CPTextField fieldAge;
    @outlet CPTextField fieldFirstName;
    @outlet CPTextField fieldLastName;
    @outlet CPTextField fieldLogin;
}

- (void)bindDataView
{
    [super bindDataView];

    [fieldAge bind:CPValueBinding toObject:_objectValue withKeyPath:@"status" options:nil];
    [fieldFirstName bind:CPValueBinding toObject:_objectValue withKeyPath:@"description" options:nil];
    [fieldLastName bind:CPValueBinding toObject:_objectValue withKeyPath:@"title" options:nil];
    [fieldLogin bind:CPValueBinding toObject:_objectValue withKeyPath:@"login" options:nil];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldAge = [aCoder decodeObjectForKey:@"fieldAge"];
        fieldFirstName = [aCoder decodeObjectForKey:@"fieldFirstName"];
        fieldLastName = [aCoder decodeObjectForKey:@"fieldLastName"];
        fieldLogin = [aCoder decodeObjectForKey:@"fieldLogin"];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldAge forKey:@"fieldAge"];
    [aCoder encodeObject:fieldFirstName forKey:@"fieldFirstName"];
    [aCoder encodeObject:fieldLastName forKey:@"fieldLastName"];
    [aCoder encodeObject:fieldLogin forKey:@"fieldLogin"];
}

@end
```

Now that we have the code of our Data Views, we need to add a xib file.
Open your project with XcodeCapp, Open Xcode and edit `SharedDataViews.xib` (provided by default in the Starter Kit).

Drop 3 views, set the class names to be respectively `SKListDataView`, `SKTaskDataView` and `SKUserDataView`.
Add the corresponding controls corresponding to the outlets you've just declared in each of the view and attach them.

Finally, bind the 3 data view to their respective outlets in the DataViewLoader (File Owner of the xib).

> This is all Cappuccino standard. If you are not familiar with any of this, please visit http://cappuccino-project.org

Data Views are now ready to be used in the NUModules.


### Create the NUModule for the Lists, Tasks and their Xib Files

Our NUKit Core Module will be the NUModule who manages the lists. It will be the first visible module. Let's start with this one.

Create a new file `ViewControllers/SKListsModule.j` and make it look like:

```objj
@import <Foundation/Foundation.j>
@import <NUKit/NUModule.j>
@import "../Models/Models.j"

@class SKTasksModule


@implementation SKListsModule : NUModule
{
    @outlet SKTasksModule tasksModule;
}

+ (CPString)moduleName
{
    return @"Lists";
}

+ (CPImage)moduleIcon
{
    return [SKList icon];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerDataViewWithName:@"listDataView" forClass:SKList];

    [self setSubModules:[tasksModule]];
}

- (void)configureContexts
{
    var context = [[NUModuleContext alloc] initWithName:@"Lists" identifier:[SKList RESTName]];
    [context setPopover:popover];
    [context setFetcherKeyPath:@"childrenLists"];
    [self registerContext:context forClass:SKList];
}

- (BOOL)shouldManagePushOfType:(CPString)aType forEntityType:(CPString)entityType
{
    return entityType === [SKLit RESTName];
}

- (BOOL)shouldProcessJSONObject:(id)aJSONObject ofType:(CPString)aType eventType:(CPString)anEventType
{
    return (aType === [SKLit RESTName]);
}

@end
```

Create a new file `ViewControllers/SKTasksModule.j` and make it look like:

```objj
@import <Foundation/Foundation.j>
@import <NUKit/NUModule.j>
@import "../Models/Models.j"


@implementation SKTasksModule : NUModule

+ (CPString)moduleName
{
    return @"Tasks";
}

+ (CPImage)moduleIcon
{
    return [SKTask icon];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self registerDataViewWithName:@"taskDataView" forClass:SKTask];
}

- (void)configureContexts
{
    var context = [[NUModuleContext alloc] initWithName:@"Tasks" identifier:[SKTask RESTName]];
    [context setPopover:popover];
    [context setFetcherKeyPath:@"childrenTasks"];
    [self registerContext:context forClass:SKTask];
}

@end
```

> We'll come back to the users module later.

Then, declare your controllers in `ViewControllers/ViewControllers.j`. Edit the file and make it look like:

```objj
@import "SKListsModule.j"
@import "SKTasksModule.j"
```

Now we need to create Xibs for these Modules. NUKit provides several templates that can be used as a starting point for creating various kind of interface. Let's use the `NodeModule.xib` for the lists, and the `LeafModule.xib` for the tasks:

    cp ./Libraries/NUKit/Tools/xibs/NodeModule.xib ./Resources/Lists.xib
    cp ./Libraries/NUKit/Tools/xibs/LeafModule.xib ./Resources/Tasks.xib

Now edit the `Lists.xib` in order to:

- set the file owner class to `SKListsModule`
- edit the popover to have:
    - One text field with:
        - A runtime attribute `tag` of type `string` set to `title`
        - A runtime attribute `required` of type `boolean` set to `true`
    - One text field with:
        - A runtime attribute `tag` of type `string` set to `description`
    - Change the validation field above the title text field to have:
        - A runtime attribute `tag` of type `string` set to `validation_title`
    - Change the validation field above the description text field to have:
        - A runtime attribute `tag` of type `string` set to `validation_description`
 - Add a new View Controller:
    - Set the class name to be `SKTasksModule`
    - Set the xib name to be `Tasks`
    - Bind it the File Owner `tasksModule` outlet

Then edit the `Tasks.xib` in order to:

- set the file owner class to `SKTasksModule`
- edit the popover to have two Text Fields:
    - One text field with:
        - A runtime attribute `tag`of type `string` set to `title`
        - A runtime attribute `required` of type `boolean` set to `true`
    - One text field with:
        - A runtime attribute `tag`of type `string` set to `description`
    - One pop up button with:
        - A runtime attribute `tag` set to `status`
        - One CPMenu item named `Todo` with:
            - A runtime attribute `tag` of type `string` set to `TODO`
        - One CPMenu item named `Done` with:
            - A runtime attribute `tag` of type `string` set to `DONE`
    - Change the validation field above the title text field to have:
        - A runtime attribute `tag` of type `string` set to `validation_title`
    - Change the validation field above the description text field to have:
        - A runtime attribute `tag` of type `string` set to `validation_description`

### Declare your Core Module in the AppController.

Last thing to do before we can actually launch our application!

Edit the `AppController.j`, and make it look like:

```objj
/*
    Header
*/

@import <Foundation/Foundation.j>
@import <NUKit/NUAssociators.j>
@import <NUKit/NUCategories.j>
@import <NUKit/NUControls.j>
@import <NUKit/NUDataSources.j>
@import <NUKit/NUDataViews.j>
@import <NUKit/NUDataViewsLoaders.j>
@import <NUKit/NUHierarchyControllers.j>
@import <NUKit/NUKit.j>
@import <NUKit/NUModels.j>
@import <NUKit/NUModules.j>
@import <NUKit/NUSkins.j>
@import <NUKit/NUTransformers.j>
@import <NUKit/NUUtils.j>
@import <NUKit/NUWindowControllers.j>
@import <Bambou/Bambou.j>

@import "DataViews/DataViewsLoader.j"
@import "Models/Models.j"
@import "ViewControllers/ViewControllers.j"

@global BRANDING_INFORMATION
@global SERVER_AUTO_URL
@global APP_BUILDVERSION
@global APP_GITVERSION


@implementation AppController : CPObject
{
    @outlet DataViewsLoader dataViewsLoader;
    @outlet SKListsModule   listsModule;
}


#pragma mark -
#pragma mark Initialization

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    [CPMenu setMenuBarVisible:NO];
    [dataViewsLoader load];

    // Configure NUKit
    [[NUKit kit] setCompanyName:BRANDING_INFORMATION["label-company-name"]];
    [[NUKit kit] setCompanyLogo:CPImageInBundle("Branding/logo-company.png")];
    [[NUKit kit] setApplicationName:BRANDING_INFORMATION["label-application-name"]];
    [[NUKit kit] setApplicationLogo:CPImageInBundle("Branding/logo-application.png")];
    [[NUKit kit] setCopyright:@"My copyright"];
    [[NUKit kit] setAutoServerBaseURL:SERVER_AUTO_URL];
    [[NUKit kit] setDelegate:self];

    [[NUKit kit] parseStandardApplicationArguments];
    [[NUKit kit] loadFrameworkDataViews];

    [[NUKit kit] setRESTUser:[SKRoot defaultUser]];

    // Modules Registration
    [[NUKit kit] registerCoreModule:listsModule];

    // Make NUKit listening to internal notifications.
    [[NUKit kit] startListenNotification];
    [[NUKit kit] manageLoginWindow];
}

- (IBAction)openInspector:(id)aSender
{
    [[NUKit kit] openInspectorForSelectedObject];
}

@end
```

Finally edit the `MainMenu.xib`, in order to:

- Add a new View Controller:
    - Set the class name to `SKListsModule`
    - Set the xib name to `Lists`
    - Bind it the `App Delegate`'s `listsModule` outlet


## Launch the Application

Now simply ensure your server is running, Then open `index-debug.html`.

You can log in with any credentials, and you need to set the server URL to be `http://127.0.0.1:3000`
