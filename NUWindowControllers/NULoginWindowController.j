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

@global CPApp
@global NUKit

NULoginWindowControllerLoggedIn     = @"NULoginWindowControllerLoggedIn";
NULoginWindowControllerLoggedOut    = @"NULoginWindowControllerLoggedOut";

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
    [labelCopyright setStringValue:[[NUKit kit]  copyright]];
    [self _launchAnimationLabelCopyright];

    [imageViewLogo setImage:CPImageInBundle("Branding/logo-application.png")];

    // Window animation
    [[self window] setFullPlatformWindow:YES];
    [self window]._windowView._DOMElement.style.WebkitAnimationName = "scaleIn";
    [self window]._windowView._DOMElement.style.WebkitTransform = "translateZ(0)";
    [self window]._windowView._DOMElement.style.WebkitBackfaceVisibility = "hidden";
    [self window]._windowView._DOMElement.style.WebkitAnimationDuration = "0.5s";
    [self window]._windowView._DOMElement.style.WebkitAnimationFillMode = "forwards";
    [self window]._windowView._DOMElement.style.WebkitAnimationFillMode = "forwards";

    [self window]._windowView._DOMElement.style.MozAnimationName = "scaleIn";
    [self window]._windowView._DOMElement.style.MozTransform = "translateZ(0)";
    [self window]._windowView._DOMElement.style.MozBackfaceVisibility = "hidden";
    [self window]._windowView._DOMElement.style.MozAnimationDuration = "0.5s";

    [self window]._windowView._DOMElement.style.animationName = "scaleIn";
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

    var bundle = [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"];

    [buttonLogin setBordered:NO];
    [buttonLogin setButtonType:CPMomentaryChangeButton];
    [buttonLogin setValue:CPImageInBundle("button-login.png", 24, 24, bundle) forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [buttonLogin setValue:CPImageInBundle("button-login-pressed.png", 24, 24, bundle) forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    _cucappID(buttonLogin, @"button-login");

    _cucappID(fieldLogin, "field-login");
    _cucappID(fieldPassword, "field-password");
    _cucappID(fieldEnterprise, "field-enterprise");
    _cucappID(fieldRESTURL, "field-restaddress");
    _cucappID(buttonLogin, "button-login");
}

#pragma mark -
#pragma mark Logic

- (void)performAutoLoginWithUserName:(CPString)aUserName organization:(CPString)anOrganization password:(CPString)aPassword url:(CPString)anURL
{
    [[CPUserDefaults standardUserDefaults] setObject:anURL forKey:@"NUAPIURL"];

    var URL = [self _computeRestBaseURL];

    [[NURESTLoginController defaultController] setUser:aUserName];
    [[NURESTLoginController defaultController] setCompany:anOrganization];
    [[NURESTLoginController defaultController] setPassword:aPassword];
    [[NURESTLoginController defaultController] setURL:URL];
    [[NURESTLoginController defaultController] setAPIKey:nil];

    [[[NUKit kit]  RESTUser] setID:nil];
    [[[NUKit kit]  RESTUser] fetchAndCallSelector:@selector(_didFetchUser:connection:) ofObject:self];
}

- (void)performAutoLoginWithUserInfo:(CPString)someUserInfo organization:(CPString)anOrganization url:(CPString)anURL
{
    [[CPUserDefaults standardUserDefaults] setObject:anURL forKey:@"NUAPIURL"];

    var URL = [self _computeRestBaseURL],
        JSONinfo = JSON.parse(atob(someUserInfo));

    [[[NUKit kit]  RESTUser] objectFromJSON:JSONinfo];

    [[NURESTLoginController defaultController] setUser:[[[NUKit kit]  RESTUser] userName]];
    [[NURESTLoginController defaultController] setCompany:anOrganization];
    [[NURESTLoginController defaultController] setPassword:nil];
    [[NURESTLoginController defaultController] setURL:URL];
    [[NURESTLoginController defaultController] setAPIKey:[[[NUKit kit]  RESTUser] APIKey]];

    [self _loginComplete];
}

- (void)performLogIn
{
    [buttonLogin setEnabled:NO];

    [self setMessage:@"Connecting..."];

    var theURL = [fieldRESTURL stringValue].replace(/ /g, "");

    if (theURL != @"auto" && theURL != @"" && theURL)
        theURL = [CPURL URLWithString:[fieldRESTURL stringValue]];

    var defaults = [CPUserDefaults standardUserDefaults];
    [defaults setObject:theURL forKey:@"NUAPIURL"];
    [defaults setObject:[fieldLogin stringValue] forKey:@"RESTServerUserName"];
    [defaults setObject:[fieldEnterprise stringValue] forKey:@"RESTServerUserCompany"];

    var currentFullURL = [self _computeRestBaseURL];
    [[NURESTLoginController defaultController] reset];
    [[NURESTLoginController defaultController] setUser:[fieldLogin stringValue]];
    [[NURESTLoginController defaultController] setCompany:[fieldEnterprise stringValue]];
    [[NURESTLoginController defaultController] setPassword:[fieldPassword stringValue]];
    [[NURESTLoginController defaultController] setURL:currentFullURL];

    // get user informations
    [[[NUKit kit]  RESTUser] setID:nil];
    [[[NUKit kit]  RESTUser] fetchAndCallSelector:@selector(_didFetchUser:connection:) ofObject:self];
}

- (void)_didFetchUser:(id)anUser connection:(NURESTConnection)aConnection
{
    // remove the clear password from memory
    [[NURESTLoginController defaultController] setPassword:nil];
    [fieldPassword setStringValue:@""];

    switch ([aConnection responseCode])
    {
        case NURESTConnectionResponseCodeNotFound:
            [self shakeWindow];
            [self setMessage:@"Resource not found"];
            [self showWindow:nil];
            [buttonLogin setEnabled:YES];
            break;

        case NURESTConnectionResponseCodeUnauthorized:
            [self shakeWindow];
            [self setMessage:@"Invalid credentials"];
            [self showWindow:nil];
            [buttonLogin setEnabled:YES];
            break;

        case NURESTConnectionResponseCodeConflict:
            [self shakeWindow];
            var responseObject = [[aConnection responseData] JSONObject];
            if (responseObject)
                [self setMessage:responseObject.errors[0].descriptions[0].title];
            else
                [self setMessage:@"Unknown connection error"];
            [buttonLogin setEnabled:YES];
            [self showWindow:nil];
            break;

        case NURESTConnectionResponseCodeSuccess:
            [[[NUKit kit]  RESTUser] setEnterpriseName:[fieldEnterprise stringValue]];

            // define the API Token from the newly fecthed current user
            [[NURESTLoginController defaultController] setAPIKey:[[[NUKit kit]  RESTUser] APIKey]];

            if (![[self window] isVisible])
            {
                [self _loginComplete];
                return;
            }

            [labelCopyright setHidden:YES];

            [self window]._windowView._DOMElement.style.WebkitAnimationName = "scaleOut";
            [self window]._windowView._DOMElement.style.MozAnimationName = "scaleOut";
            [self window]._windowView._DOMElement.style.animationName = "scaleOut";

            var endFunction = function() {
                [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
                [self window]._windowView._DOMElement.removeEventListener("webkitAnimationEnd", arguments.callee, NO);
                [self window]._windowView._DOMElement.removeEventListener("animationend", arguments.callee, NO);
                [[self window] close];

                [buttonLogin setEnabled:YES];

                [self _loginComplete];
            };

            [self window]._windowView._DOMElement.addEventListener("webkitAnimationEnd", endFunction, NO);
            [self window]._windowView._DOMElement.addEventListener("animationend", endFunction, NO);
            break;

        default:
            [self shakeWindow];
            [self setMessage:@"Unable to connect to the endpoint"];
            [buttonLogin setEnabled:YES];
            [self showWindow:nil];
    }
}

- (void)performLogOut
{
    [self window]._windowView._DOMElement.style.WebkitAnimationName = "scaleIn";
    [self window]._windowView._DOMElement.style.animationName = "scaleIn";
    [self window]._windowView._DOMElement.style.MozAnimationName = "scaleIn";

    [[NURESTLoginController defaultController] reset];

    [self setMessage:@""];
    [buttonLogin setEnabled:YES];
    [labelCopyright setHidden:NO];
    [self _launchAnimationLabelCopyright];
}

- (void)_loginComplete
{
    [[CPNotificationCenter defaultCenter] postNotificationName:NULoginWindowControllerLoggedIn object:self userInfo:nil];
}


#pragma mark -
#pragma mark Utilities

- (void)shakeWindow
{
/*    [[EKShakeAnimation alloc] initWithView:[self window]._windowView];*/
}

- (void)_launchAnimationLabelCopyright
{
    labelCopyright._DOMElement.style.opacity = 0.0;
    labelCopyright._DOMElement.style.transition = "opacity 1s 3s";
    labelCopyright._DOMElement.style.webkitTransition = "opacity 1s 3s";
    labelCopyright._DOMElement.style.mozTransition = "opacity 1s 3s";
}

- (void)setMessage:(CPString)aValue
{
    [labelInfo setStringValue:aValue];
}

- (CPString)_computeBrowserLocationOrigin
{
    var origin = window.location.origin;

    if (!origin || typeof(origin) == "undefined")
    {
        var protocol = window.location.protocol,
            hostname = window.location.hostname,
            port = window.location.port;

        origin = protocol + "//" + hostname;
        if (port && port != @"")
            origin += ":" + port;
    }

    return origin;
}

- (CPURL)_computeRestBaseURL
{
    var defaults        = [CPUserDefaults standardUserDefaults],
        bundle          = [CPBundle mainBundle],
        baseURLString   = [defaults objectForKey:@"NUAPIURL"],
        baseURL         = [CPURL URLWithString:baseURLString[baseURLString.lenght - 1] != @"/" ? baseURLString + @"/" : baseURLString],
        APIVersion      = @"v" + [bundle objectForInfoDictionaryKey:@"NUAPIVersion"].replace(".", "_"),
        finalRESTURL;

    var customAPIVersion = _get_query_parameter_with_name("apiversion");
    if (customAPIVersion)
        APIVersion = customAPIVersion;

    if (baseURL == @"auto/")
        baseURL = [CPURL URLWithString:[self _computeBrowserLocationOrigin] + @"/"];

    finalRESTURL = [CPURL URLWithString:("nuage/api/" + APIVersion + "/") relativeToURL:baseURL];

    CPLog.info("REST URL base is set to %@", finalRESTURL);

    return finalRESTURL;
}

- (void)makeCorrectFirstResponder
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
    [self performLogIn];
}

- (IBAction)showWindow:(id)aSender
{
    document.body.style.backgroundImage = "red"
    [[self window] setDefaultButton:buttonLogin];
    [[self window] setDelegate:self];
    [[self window] center];

    var defaults = [CPUserDefaults standardUserDefaults];
    [fieldRESTURL setStringValue:[defaults objectForKey:@"NUAPIURL"] || @"auto"];
    [fieldLogin setStringValue:[defaults objectForKey:@"RESTServerUserName"] || @""];
    [fieldEnterprise setStringValue:[defaults objectForKey:@"RESTServerUserCompany"] || @""];

    [super showWindow:aSender];
    [[self window] makeKeyWindow];

    // small hack
    setTimeout(function(){
        [self makeCorrectFirstResponder];

        labelCopyright._DOMElement.style.opacity = 0.4;
    }, 0);
}

- (void)close
{
    [super close];

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
