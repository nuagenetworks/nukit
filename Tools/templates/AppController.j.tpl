/*
*   Filename:         AppController.j
*   Created:          Tue Oct  9 11:56:38 PDT 2012
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          Cloud Network Automation - Nuage - Data Center Service Delivery - IPD
*
* Copyright (c) 2011-2012 Alcatel, Alcatel-Lucent, Inc. All Rights Reserved.
*
* This source code contains confidential information which is proprietary to Alcatel.
* No part of its contents may be used, copied, disclosed or conveyed to any party
* in any manner whatsoever without prior written permission from Alcatel.
*
* Alcatel-Lucent is a trademark of Alcatel-Lucent, Inc.
*
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

// first import basic things
@import "Resources/Branding/branding.js"
@import "Resources/app-version.js"

@import "DataViews/{{class_prefix}}DataViewsLoader.j"
@import "Models/{{class_prefix}}Models.j"
@import "ViewControllers/{{class_prefix}}ViewControllers.j"

@global open

@implementation AppController : CPObject
{
    @outlet {{class_prefix}}DataViewsLoader dataViewsLoader;

    // declare your main controller here
}


#pragma mark -
#pragma mark Initialization

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    [CPMenu setMenuBarVisible:NO];

    [dataViewsLoader load];

    // configure NUKit

    [[NUKit kit] setCompanyName:BRANDING_INFORMATION["label-company-name"]];
    [[NUKit kit] setCompanyLogo:CPImageInBundle("Branding/logo-company.png")];
    [[NUKit kit] setApplicationName:BRANDING_INFORMATION["label-application-name"]];
    [[NUKit kit] setApplicationLogo:CPImageInBundle("Branding/logo-application.png")];
    [[NUKit kit] setCopyright:[self _copyrightString]];

    [[NUKit kit] parseStandardApplicationArguments];
    [[NUKit kit] loadFrameworkDataViews];
    [[NUKit kit] setDelegate:self];

    // set the root object here
    // [[NUKit kit] setRESTUser:[TODOMyRootObject defaultUser]];

    [[NUKitToolBar defaultToolBar] setBorderBottomColor:NUSkinColorGreyDark];

    // register your core module
    //[[NUKit kit] registerCoreModule:TODOMyCoreModule];

    // register a principal module if needed
    // [[NUKit kit] registerPrincipalModule:VCenterConfigurationsController
    //                      withButtonImage:CPImageInBundle(@"toolbar-config.png", 32.0, 32.0)
    //                             altImage:CPImageInBundle(@"toolbar-config-pressed.png", 32.0, 32.0)
    //                             toolTip:@"Open configurations"
    //                          identifier:@"button-toolbar-config"
    //                    availableToRoles:nil];


    [[NUKit kit] startListenNotification];
    [[NUKit kit] manageLoginWindow];
}


#pragma mark -
#pragma mark Actions

- (IBAction)openInspector:(id)aSender
{
    [[NUKit kit] openInspectorForSelectedObject];
}


#pragma mark -
#pragma mark Copyright

- (CPString)_copyrightString
{
    var copyright = BRANDING_INFORMATION["label-company-name"];

    if (!copyright || !copyright.length)
        return [CPString stringWithFormat:@"Version %@ (%@)", APP_BUILDVERSION, APP_GITVERSION];
    else
        return [CPString stringWithFormat:@"Copyright \u00A9 %@ %@ - %@ (%@)", new Date().getFullYear(), copyright, APP_BUILDVERSION, APP_GITVERSION];
}

@end
