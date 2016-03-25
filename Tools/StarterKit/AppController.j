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
@import "Transformers/Transformers.j"

@global BRANDING_INFORMATION
@global SERVER_AUTO_URL
@global APP_BUILDVERSION
@global APP_GITVERSION


@implementation AppController : CPObject
{
    @outlet DataViewsLoader dataViewsLoader;
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
    [[NUKit kit] setCopyright:@"copyright me forever"];
    [[NUKit kit] setAutoServerBaseURL:SERVER_AUTO_URL];
    [[NUKit kit] setDelegate:self];
    [[NUKit kit] parseStandardApplicationArguments];
    [[NUKit kit] loadFrameworkDataViews];

    [[[NUKit kit] loginWindowController] setShowsEnterpriseField:NO];

    // the root object here
    // [[NUKit kit] setRootAPI:[MyRootObject current]];

    // Modules Registration
    // [[NUKit kit] registerCoreModule:coreModule];

    // Make NUKit listening to internal notifications.
    [[NUKit kit] startListenNotification];

    // Shows the login window
    [[NUKit kit] manageLoginWindow];
}

- (IBAction)openInspector:(id)aSender
{
    [[NUKit kit] openInspectorForSelectedObject];
}

- (void)applicationDidLogin:(NUKit)aKit
{
    // makes everyone a super user!
    // [[MyRootObject current] setRole:NUPermissionLevelRoot];
}

@end
