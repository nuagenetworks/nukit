@import <Foundation/Foundation.j>
@import <NUKit/NUModuleItemized.j>

// declate the modules that will be itemized
@class Module1
@class Module2


@implementation NUItemizedVPNsViewController : NUModuleItemized
{
    // add your outlets
    @outlet Module1 module1;
    @outlet Module2 module2;
}


#pragma mark -
#pragma mark Initialization

+ (CPString)moduleName
{
    // Returns the name of the module
    return @"Itemized";
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // set the submodules
    [self setSubModules:[module1, module2]];
}


#pragma mark -
#pragma mark NUItemizedModule API

// Returns the list of active items
- (CPArray)moduleItemizedCurrentItems
{
    return [{"module": module1, "children": nil}, {"module": module2, "children": nil}];
}

@end
