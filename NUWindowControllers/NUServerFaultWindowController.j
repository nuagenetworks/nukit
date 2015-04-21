/*
*   Filename:         NUServerFaultWindowController.j
*   Created:          Tue Oct  9 11:56:28 PDT 2012
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
@import <AppKit/CPWindowController.j>

@global CPApp

/*! Control the window displayed when server is unreachable
*/
@implementation NUServerFaultWindowController : CPWindowController
{
    @outlet CPImageView imageViewLogo;
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    self = [super initWithWindowCibName:@"ServerFault"]

    return self;
}

- (void)windowDidLoad
{
    var contentView = [[self window] contentView];

    [[contentView subviewWithTag:@"logout"] setBGColor:@"red"];

    [imageViewLogo setImage:CPImageInBundle("Branding/logo-application.png")];

    [self window]._windowView._DOMElement.style.WebkitAnimationName = "bounceInDown";
    [self window]._windowView._DOMElement.style.WebkitTransform = "translateZ(0)";
    [self window]._windowView._DOMElement.style.WebkitAnimationDuration  = "1s";
    [self window]._windowView._DOMElement.style.backgroundColor = "rgba(255, 255, 255, 0.8)";
}


#pragma mark -
#pragma mark Utilities

- (IBAction)logOut:(id)aSender
{
    [[NUKit kit] performLogout];
}

- (IBAction)showWindow:(id)aSender
{
    [[self window] center];
    [super showWindow:aSender];
}


#pragma mark -
#pragma mark Overrides

// TODO: this is insane, I guess Cocoa has a way to specify the bundle instead of overrides these two methos

- (void)loadWindow
{
    if (_window)
        return;

    [[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"] loadCibFile:[self windowCibPath] externalNameTable:@{ CPCibOwner: _cibOwner }];
}

- (CPString)windowCibPath
{
    if (_windowCibPath)
        return _windowCibPath;

    return [[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"] pathForResource:_windowCibName + @".cib"];
}

@end
