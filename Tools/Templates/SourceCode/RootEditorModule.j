@import <Foundation/Foundation.j>
@import <NUKit/NUModule.j>
@import "../../Models/Models.j"

// declare the editor modules
@class FirstEditorModule
@class SecondEditorModule


@implementation RootEditorModule : NUModule
{
    // declare your outlets
    @outlet FirstEditorModule  firstEditorModule;
    @outlet SecondEditorModule secondEditorModule;
}


#pragma mark -
#pragma mark Initialization

+ (CPString)moduleName
{
    // return the name of the module
    return @"Editor";
}

+ (BOOL)isTableBasedModule
{
    return NO;
}

+ (BOOL)moduleTabViewMode
{
    return NUModuleTabViewModeIcon;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // set the submodules
    [self setSubModules:[firstEditorModule, secondEditorModule]];
}


#pragma mark -
#pragma mark NUModule API

// this method is optional, and you can remove it.
// but this this how to can add logic to decide what editor
// should be visible according to any custom logic.
- (CPArray)currentActiveSubModules
{
    var controllers = [];

    [controllers addObject:firstEditorModule];

    if (1 > 2)
        [controllers addObject:secondEditorModule];

    return controllers;
}

@end
