@import <Foundation/Foundation.j>
@import <NUKit/NUModuleAssignation.j>
@import "../Models/Models.j"


@implementation AssignationModule : NUModuleAssignation

+ (CPString)moduleName
{
    // set the module name
    return @"Objects";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // register your data view
    [self registerDataViewWithName:@"objectsDataView" forClass:ObjectClass];
}

- (void)configureContexts
{
    // configure the context
    var context = [[NUModuleContext alloc] initWithName:@"Objects" identifier:[ObjectClass RESTName]];
    [context setPopover:popover];
    [context setFetcherKeyPath:@"childrenObjects"];
    [self registerContext:context forClass:ObjectClass];
}


#pragma mark -
#pragma mark NUModuleAssignation API

- (void)configureObjectsChooser:(NUObjectChooser)anObjectChooser
{

    [anObjectChooser setModuleTitle:"Select Associated Objects"];
    [anObjectChooser registerDataViewWithName:@"associatedObjectsDataView" forClass:AssociatedObjectClass];
}

- (NUVSDObject)parentOfAssociatedObject
{
    // set the parent of AssociatedObjectClass
    return [NURESTUser defaultUser];
}

- (void)assignObjects:(CPArray)someObjects
{
    // perform the association
    [_currentParent assignEntities:someObjects
                           ofClass:NUMulticastChannelMap
                   andCallSelector:nil
                          ofObject:nil];
}

@end
