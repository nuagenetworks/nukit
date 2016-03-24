@import <Foundation/Foundation.j>
@import <NUKit/NUModule.j>
@import "../Models/Models.j"


@implementation CoreModule : NUModule
{
    // declare your sub modules
    @outlet SubModule subModule1;
}

+ (BOOL)automaticSelectionSaving
{
    return NO;
}

+ (CPString)moduleName
{
    // set the name of the module
    return @"Objects";
}

+ (CPImage)moduleIcon
{
    // set return the icon for the module
    return [ObjectClass icon];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // register your data view
    [self registerDataViewWithName:@"objectDataView" forClass:SKList];

    // register your submodules
    [self setSubModules:[subModule1]];
}

- (void)configureContexts
{
    // configure your context
    var context = [[NUModuleContext alloc] initWithName:@"Objects" identifier:[ObjectClass RESTName]];
    [context setPopover:popover];
    [context setFetcherKeyPath:@"childrenObjects"];
    [self registerContext:context forClass:ObjectClass];
}

// force accepting the push management for the managed model
- (BOOL)shouldManagePushOfType:(CPString)aType forEntityType:(CPString)entityType
{
    return entityType === [ObjectClass RESTName];
}

// force accepting the push processing for the managed model
- (BOOL)shouldProcessJSONObject:(id)aJSONObject ofType:(CPString)aType eventType:(CPString)anEventType
{
    return (aType === [ObjectClass RESTName]);
}

@end
