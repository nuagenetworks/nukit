/*
*   Filename:         NULoginWindowController.j
*   Created:          Tue Oct  9 11:56:13 PDT 2012
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
@import <AppKit/CPButton.j>
@import <AppKit/CPSecureTextField.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPWindowController.j>
@import <AppKit/CPSound.j>

@import "NUSkin.j"
@import "NUUtilities.j"
@import "NUDataTransferController.j"
@import "EKShakeAnimation.j"

@class NUKit

@global CPApp


@implementation NULoginWindowController : CPWindowController
{
    @outlet CPButton            buttonLogin;
    @outlet CPImageView         imageViewLogo;
    @outlet CPSecureTextField   fieldPassword;
    @outlet CPTextField         fieldEnterprise;
    @outlet CPTextField         fieldLogin;
    @outlet CPTextField         fieldRESTURL;
    @outlet CPTextField         labelCopyright;
    @outlet CPTextField         labelInfo;
    @outlet CPView              viewContainer;
}

#pragma mark -
#pragma mark Initialization

- (id)init
{
    self = [self initWithWindowCibName:@"Login"];

    return self;
}

- (void)windowDidLoad
{
    [labelCopyright setStringValue:[[NUKit kit] copyright]];
    [imageViewLogo setImage:[[NUKit kit] applicationLogo]];
    [labelCopyright setHidden:YES];
    [labelCopyright setAlphaValue:0.4];

    // Window animation
    [[self window] setFullPlatformWindow:YES];
    [self window]._windowView._DOMElement.style.WebkitTransform = "translateZ(0)";
    [self window]._windowView._DOMElement.style.WebkitBackfaceVisibility = "hidden";
    [self window]._windowView._DOMElement.style.WebkitAnimationDuration = "0.5s";
    [self window]._windowView._DOMElement.style.WebkitAnimationFillMode = "forwards";
    [self window]._windowView._DOMElement.style.WebkitAnimationFillMode = "forwards";

    [self window]._windowView._DOMElement.style.MozTransform = "translateZ(0)";
    [self window]._windowView._DOMElement.style.MozBackfaceVisibility = "hidden";
    [self window]._windowView._DOMElement.style.MozAnimationDuration = "0.5s";

    [self window]._windowView._DOMElement.style.transform = "translateZ(0)";
    [self window]._windowView._DOMElement.style.backfaceVisibility = "hidden";
    [self window]._windowView._DOMElement.style.animationDuration = "0.5s";
    [self window]._windowView._DOMElement.style.animationFillMode = "forwards";

    // Container view skin
    viewContainer._DOMElement.style.backgroundColor = "rgba(255, 255, 255, 0.8)";

    var line = [viewContainer subviewWithTag:@"line"];
    [line setBorderColor:NUSkinColorGreyDark];
    [line setBorderWidth:1.0]
    [line setAlphaValue:0.3];

    [buttonLogin setBordered:NO];
    [buttonLogin setButtonType:CPMomentaryChangeButton];
    [buttonLogin setValue:NUImageInKit(@"button-login.png", 24, 24) forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [buttonLogin setValue:NUImageInKit(@"button-login-pressed.png", 24, 24) forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    _cucappID(buttonLogin, @"button-login");

    _cucappID(fieldLogin, "field-login");
    _cucappID(fieldPassword, "field-password");
    _cucappID(fieldEnterprise, "field-enterprise");
    _cucappID(fieldRESTURL, "field-restaddress");
    _cucappID(buttonLogin, "button-login");
}


#pragma mark -
#pragma mark Utilities

- (void)shakeWindow
{
    [[EKShakeAnimation alloc] initWithView:[self window]._windowView];
}

- (void)setMessage:(CPString)aValue
{
    [labelInfo setStringValue:aValue];
}

- (void)setButtonLoginEnabled:(BOOL)shouldEnable
{
    [buttonLogin setEnabled:shouldEnable];
}

- (void)emptyPasswordField
{
    [fieldPassword setStringValue:@""];
}

- (void)_makeCorrectFirstResponder
{
    [[self window] makeFirstResponder:nil];

    if ([fieldLogin stringValue] != @"")
        [[self window] makeFirstResponder:fieldPassword];
    else
        [[self window] makeFirstResponder:fieldLogin];
}


#pragma mark -
#pragma mark Actions

- (IBAction)logIn:(id)aSender
{
    [self setButtonLoginEnabled:NO];
    [self setMessage:@"Connecting..."];
    [[NUKit kit] performLoginWithUserName:[fieldLogin stringValue] organization:[fieldEnterprise stringValue] password:[fieldPassword stringValue] url:[fieldRESTURL stringValue]];
}

- (IBAction)showWindow:(id)aSender
{
    if ([[self window] isVisible])
        return;

    var defaults = [CPUserDefaults standardUserDefaults];
    [fieldRESTURL setStringValue:[defaults objectForKey:@"NUAPIURL"] || @"auto"];
    [fieldLogin setStringValue:[defaults objectForKey:@"RESTServerUserName"] || @""];
    [fieldEnterprise setStringValue:[defaults objectForKey:@"RESTServerUserCompany"] || @""];

    [[self window] setDefaultButton:buttonLogin];
    [[self window] center];

    [self window]._windowView._DOMElement.style.WebkitAnimationName = "scaleIn";
    [self window]._windowView._DOMElement.style.animationName = "scaleIn";
    [self window]._windowView._DOMElement.style.MozAnimationName = "scaleIn";

    var endFunction = function()
    {
        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
        [self window]._windowView._DOMElement.removeEventListener("webkitAnimationEnd", arguments.callee, NO);
        [self window]._windowView._DOMElement.removeEventListener("animationend", arguments.callee, NO);

        [labelCopyright setHidden:NO];
    };

    [self window]._windowView._DOMElement.addEventListener("webkitAnimationEnd", endFunction, NO);
    [self window]._windowView._DOMElement.addEventListener("animationend", endFunction, NO);

    [super showWindow:aSender];
    [[self window] makeKeyWindow];
    [self _makeCorrectFirstResponder];
}

- (void)close
{
    if (![[self window] isVisible])
        return;

    [labelCopyright setHidden:YES];

    [self window]._windowView._DOMElement.style.WebkitAnimationName = "scaleOut";
    [self window]._windowView._DOMElement.style.MozAnimationName = "scaleOut";
    [self window]._windowView._DOMElement.style.animationName = "scaleOut";

    var endFunction = function()
    {
        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
        [self window]._windowView._DOMElement.removeEventListener("webkitAnimationEnd", arguments.callee, NO);
        [self window]._windowView._DOMElement.removeEventListener("animationend", arguments.callee, NO);

        [self setMessage:@""];
        [super close];
    };

    [self window]._windowView._DOMElement.addEventListener("webkitAnimationEnd", endFunction, NO);
    [self window]._windowView._DOMElement.addEventListener("animationend", endFunction, NO);

    [_CPToolTip invalidateCurrentToolTipIfNeeded];
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
