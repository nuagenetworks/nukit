/*
*   Filename:         NUKitApp.j
*   Created:          Mon Apr 20 21:39:49 PDT 2015
*   Author:           Antoine Mercadal <antoine.mercadal@alcatel-lucent.com>
*   Description:      VSA
*   Project:          VSD - Nuage - Data Center Service Delivery - IPD
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
@import @"NUServerFaultWindowController.j"
@import @"NULoginWindowController.j"
@import @"NUMessagesWindowController.j"
@import @"NUInspectorWindowController.j"
@import @"NUMainWindowController.j"

NUKitUserLoggedInNotification = @"NUKitUserLoggedInNotification";
NUKitUserLoggedOutNotification = @"NUKitUserLoggedOutNotification";

var NUKitDefaultKit;

NUKitParameterShowDebugToolTips    = NO;
NUKitParameterCat                  = NO;
NUKitParameterExperimentalMode     = NO;
NUKitParameterVeryExperimentalMode = NO;
NUKitParameterCuccapSupported      = NO;

var NUKitDelegate_didLogin_     = 1 << 1,
    NUKitDelegate_willLogout_   = 1 << 2;


@implementation NUKit : CPObject
{
    CPBundle                        _bundle                         @accessors(getter=bundle);
    CPImage                         _applicationLogo                @accessors(property=applicationLogo);
    CPImage                         _companyLogo                    @accessors(property=companyLogo);
    CPString                        _applicationName                @accessors(property=applicationName);
    CPString                        _companyName                    @accessors(property=companyName);
    CPString                        _copyright                      @accessors(property=copyright);
    id                              _RESTUser                       @accessors(property=RESTUser);
    NULoginWindowController         _loginWindowController          @accessors(getter=loginWindowController);
    NUMainWindowController          _mainWindowController           @accessors(property=mainWindowController);
    NUMessagesWindowController      _messagesWindowController       @accessors(getter=messagesWindowController);
    NUServerFaultWindowController   _serverFaultWindowController    @accessors(getter=serverFaultWindowController);

    BOOL                            _isAppClosing;
    CPArray                         _externalWindows;
    CPPopover                       _lockedPopover;
    CPView                          _lockedPopoverView;
    id                              _delegate;
    unsigned                        _implementedDelegateMethods;
}


#pragma mark -
#pragma mark Class Methods

+ (NUKit)kit
{
    if (!NUKitDefaultKit)
        NUKitDefaultKit = [NUKit new];

    return NUKitDefaultKit;
}


#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super init])
    {
        _bundle = [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"];

        [self installStyleSheetOnDocument:document];

        _externalWindows             = [];

        _loginWindowController       = [NULoginWindowController new];
        _mainWindowController        = [NUMainWindowController new];
        _messagesWindowController    = [NUMessagesWindowController new];
        _serverFaultWindowController = [NUServerFaultWindowController new];

        _lockedPopoverView = [CPView new];
        [_lockedPopoverView setBackgroundColor:NUSkinColorWhite];
        [_lockedPopoverView setAlphaValue:0.5];
        [_lockedPopoverView setInAnimation:@"fadeInHalf" duration:0.5];
        [_lockedPopoverView setOutAnimation:@"fadeOutHalf" duration:0.5];

        [[CPUserDefaults standardUserDefaults] registerDefaults:@{@"NUAPIURL": [[CPBundle mainBundle] objectForInfoDictionaryKey:@"NUAPIURL"]}];
    }

    return self;
}

- (void)loadFrameworkDataViews
{
    [[[NUInternalDataViewsLoader alloc] initWithCibName:@"DataViews" bundle:[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]] load];
}

- (void)installStyleSheetOnDocument:(id)aDocument
{
    var resourceURL = [[[self bundle] resourceURL] absoluteString],
        head        = aDocument.getElementsByTagName('head')[0],
        animatecss  = aDocument.createElement('link'),
        appcss      = aDocument.createElement('link'),
        spinnercss  = aDocument.createElement('link');

    animatecss.id    = @"animate.css";
    animatecss.rel   = @"stylesheet";
    animatecss.type  = @"text/css";
    animatecss.href  = resourceURL + @"/animate.css";
    animatecss.media = @"all";
    head.appendChild(animatecss);

    appcss.id    = @"app.css";
    appcss.rel   = @"stylesheet";
    appcss.type  = @"text/css";
    appcss.href  = resourceURL + @"/app.css";
    appcss.media = @"all";
    head.appendChild(appcss);

    spinnercss.id    = @"spinner.css";
    spinnercss.rel   = @"stylesheet";
    spinnercss.type  = @"text/css";
    spinnercss.href  = resourceURL + @"/spinner.css";
    spinnercss.media = @"all";
    head.appendChild(spinnercss);
}

- (void)registerCoreModule:(NUModule)aModule
{
    [_mainWindowController registerCoreModule:aModule];
}

- (void)registerPrincipalModule:(NUModule)aModule accessButton:(CPButton)aButton availableToRoles:(CPArray)someRoles
{
    [_mainWindowController registerPrincipalModule:aModule accessButton:aButton availableToRoles:someRoles];
}


#pragma mark -
#pragma mark Utilities

- (void)_sendLogOutNotification
{
    [[CPNotificationCenter defaultCenter] postNotificationName:NUKitUserLoggedOutNotification object:self];
}

- (void)_sendLogInNotification
{
    [[CPNotificationCenter defaultCenter] postNotificationName:NUKitUserLoggedInNotification object:self];
}


#pragma mark -
#pragma mark Notification Handlers

- (void)startListenNotification
{
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_didReceiveServerUnreachableNotification:) name:NURESTPushCenterServerUnreachable object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_didReceiveXHRErrorNotification:) name:NURESTConnectionFailureNotification object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_didReceiveUserIdleNotification:) name:NURESTConnectionIdleTimeoutNotification object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_didReceiveRESTErrorNotification:) name:NURESTErrorNotification object:nil];
    [[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(_didReceiveRESTConfirmationNotification:) name:NURESTConfirmationNotification object:nil];
}

- (void)_didReceiveServerUnreachableNotification:(CPNotification)aNotification
{
    if (_isAppClosing)
        return;

    [[self mainWindowController] close];
    [[self serverFaultWindowController] showWindow:nil];
    [self _sendLogOutNotification];
}

- (void)_didReceiveUserIdleNotification:(CPNotification)aNotification
{
    var lastUserInputTimeStamp = Math.round([[CPApp currentEvent] timestamp]),
        lastRegisteredTimeStamp = Math.round([aNotification userInfo]);

    if (lastUserInputTimeStamp - lastRegisteredTimeStamp <= 0)
    {
        [self performLogout];
        [[self loginWindowController] setMessage:@"User idle for too long"];
    }
    else
        [NURESTConnection resetIdleTimeout];
}

- (void)_didReceiveXHRErrorNotification:(CPNotification)aNotification
{
    [self performLogout];
    [[self loginWindowController] setMessage:[[aNotification userInfo] hasTimeouted] ? @"Request timeout" : @"Unknown connection error"];
}

- (void)_didReceiveRESTErrorNotification:(CPNotification)aNotification
{
    [[self messagesWindowController] pushMessage:[aNotification object]];
}

- (void)_didReceiveRESTConfirmationNotification:(CPNotification)aNotification
{
    [[self messagesWindowController] pushMessage:[aNotification object]];
}


#pragma mark -
#pragma mark Arguments Parsing

- (CPString)valueForApplicationArgument:(CPString)aString
{
   if (window.location.search && window.location.search.indexOf(aString) == -1)
       return nil;

    return _get_query_parameter_with_name(aString)
}

- (void)parseStandardApplicationArguments
{
    if ([self valueForApplicationArgument:@"debugtooltips"])
        NUKitParameterShowDebugToolTips = YES;

    if ([self valueForApplicationArgument:@"catmode"])
        NUKitParameterCat = YES;

    if ([self valueForApplicationArgument:@"legacyscrollers"])
        [CPScrollView setGlobalScrollerStyle:CPScrollerStyleLegacy];

    if ([self valueForApplicationArgument:@"debug"])
    {
        CPLogUnregister(CPLogConsole);
        CPLogRegister(CPLogConsole, "trace");
    }

    if ([self valueForApplicationArgument:@"realmanmode"])
        [NURESTConnection setAutoConfirm:YES];

    if ([self valueForApplicationArgument:@"overlymanlymanmode"])
    {
        [NURESTConnection setAutoConfirm:YES];
        [NUModule setAutoConfirm:YES]
    }

    if ([self valueForApplicationArgument:@"notimeout"])
        [NURESTConnection setTimeoutValue:nil];

    if ([self valueForApplicationArgument:@"experimental"])
        NUKitParameterExperimentalMode = YES;

    if ([self valueForApplicationArgument:@"veryexperimental"])
        NUKitParameterVeryExperimentalMode = YES;

    if ([_lockedPopoverView respondsToSelector:@selector(setCucappIdentifier:)])
        NUKitParameterCuccapSupported = YES;
}


#pragma mark -
#pragma mark External Platform Windows Mamagement

- (void)registerExternalWindow:(CPPlatformWindow)aWindow
{
    if (![_externalWindows containsObject:aWindow])
        [_externalWindows addObject:aWindow];
}

- (void)unregisterExternalWindow:(CPPlatformWindow)aWindow
{
    if ([_externalWindows containsObject:aWindow])
        [_externalWindows removeObject:aWindow];
}

- (void)closeExternalWindows
{
    var windows = [_externalWindows copy];

    for (var i = [windows count] - 1; i >= 0; i--)
        [windows[i] orderOut:nil];

/*    [NUInspectorWindowController flushInspectorRegistry];*/
}


#pragma mark -
#pragma mark Delegates

- (void)setDelegate:(id)aDelegate
{
    if (aDelegate == _delegate)
        return;

    _delegate = aDelegate;
    _implementedDelegateMethods = 0;

    if ([_delegate respondsToSelector:@selector(applicationDidLogin:)])
        _implementedDelegateMethods |= NUKitDelegate_didLogin_;

    if ([_delegate respondsToSelector:@selector(applicationWillLogout:)])
        _implementedDelegateMethods |= NUKitDelegate_willLogout_;
}

- (void)_sendDelegateDidLogin
{
    if (_implementedDelegateMethods & NUKitDelegate_didLogin_)
        [_delegate applicationDidLogin:self];
}

- (void)_sendDelegateWillLogout
{
    if (_implementedDelegateMethods & NUKitDelegate_willLogout_)
        [_delegate applicationWillLogout:self];
}


#pragma mark -
#pragma mark REST URL Management

- (CPURL)RESTBaseURL
{
    var baseURLString   = [[CPUserDefaults standardUserDefaults] objectForKey:@"NUAPIURL"],
        baseURL         = [CPURL URLWithString:baseURLString[baseURLString.lenght - 1] != @"/" ? baseURLString + @"/" : baseURLString],
        APIVersion      = @"v" + [[CPBundle mainBundle] objectForInfoDictionaryKey:@"NUAPIVersion"].replace(".", "_"),
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


#pragma mark -
#pragma mark Application Name and Icon Management

- (void)bindApplicationNameToObject:(id)anObject withKeyPath:(CPString)aKeyPath
{
    [[NUKitToolBar defaultToolBar] bindApplicationNameToObject:anObject withKeyPath:aKeyPath];
}

- (void)bindApplicationIconToObject:(id)anObject withKeyPath:(CPString)aKeyPath
{
    [[NUKitToolBar defaultToolBar] bindApplicationIconToObject:anObject withKeyPath:aKeyPath];
}


#pragma mark -
#pragma mark Session Management

- (void)manageLoginWindow
{
    var userInfo = [self valueForApplicationArgument:@"userinfo"],
        user     = [self valueForApplicationArgument:@"user"],
        org      = [self valueForApplicationArgument:@"org"],
        pass     = [self valueForApplicationArgument:@"pass"],
        api      = [self valueForApplicationArgument:@"api"] || @"auto";

    if (userInfo && api && org)
        [self performAutoLoginWithUserInfo:userInfo organization:org url:api];
    else if (user && org && pass && api)
        [self performLoginWithUserName:user organization:org password:pass url:api];
    else
        [[self loginWindowController] showWindow:self];
}

- (void)_continueLogin
{
    [[NURESTLoginController defaultController] setAPIKey:[[self RESTUser] APIKey]];
    [[NURESTPushCenter defaultCenter] start];

    [[self serverFaultWindowController] close];
    [[self loginWindowController] close];
    [[self loginWindowController] emptyPasswordField];
    [[self mainWindowController] showWindow:self];

    [[[self mainWindowController] window] platformWindow]._DOMWindow.addEventListener("beforeunload", function(){
        _isAppClosing = YES;
    }, NO);

    [self _sendLogInNotification];
    [self _sendDelegateDidLogin];

    [[NUKitToolBar defaultToolBar] setNeedsLayout];
}

- (void)performLoginWithUserName:(CPString)aUserName organization:(CPString)anOrganization password:(CPString)aPassword url:(CPString)anURL
{
    anURL = anURL.replace(/ /g, "");
    if (anURL != @"auto" && anURL != @"" && anURL)
        anURL = [CPURL URLWithString:anURL];

    [[CPUserDefaults standardUserDefaults] setObject:anURL forKey:@"NUAPIURL"];
    [[CPUserDefaults standardUserDefaults] setObject:aUserName forKey:@"RESTServerUserName"];
    [[CPUserDefaults standardUserDefaults] setObject:anOrganization forKey:@"RESTServerUserCompany"];

    var finalURL = [self RESTBaseURL];

    [[NURESTLoginController defaultController] setUser:aUserName];
    [[NURESTLoginController defaultController] setCompany:anOrganization];
    [[NURESTLoginController defaultController] setPassword:aPassword];
    [[NURESTLoginController defaultController] setURL:finalURL];
    [[NURESTLoginController defaultController] setAPIKey:nil];

    [[self RESTUser] setID:nil];
    [[self RESTUser] fetchAndCallSelector:@selector(_didFetchUser:connection:) ofObject:self];
}

- (void)performAutoLoginWithUserInfo:(CPString)someUserInfo organization:(CPString)anOrganization url:(CPString)anURL
{
    [[CPUserDefaults standardUserDefaults] setObject:anURL forKey:@"NUAPIURL"];

    var URL      = [self RESTBaseURL],
        JSONinfo = JSON.parse(atob(someUserInfo));

    [[self RESTUser] objectFromJSON:JSONinfo];

    [[NURESTLoginController defaultController] setUser:[[self RESTUser] userName]];
    [[NURESTLoginController defaultController] setCompany:anOrganization];
    [[NURESTLoginController defaultController] setPassword:nil];
    [[NURESTLoginController defaultController] setURL:URL];
    [[NURESTLoginController defaultController] setAPIKey:[[self RESTUser] APIKey]];

    [self _continueLogin];
}

- (void)_didFetchUser:(id)anUser connection:(NURESTConnection)aConnection
{
    [[NURESTLoginController defaultController] setPassword:nil];
    [[self loginWindowController] setButtonLoginEnabled:YES];

    switch ([aConnection responseCode])
    {
        case NURESTConnectionResponseCodeSuccess:
            [self _continueLogin];
            break;

        case NURESTConnectionResponseCodeNotFound:
            [[self loginWindowController] setMessage:@"Resource not found"];
            break;

        case NURESTConnectionResponseCodeUnauthorized:
            [[self loginWindowController] setMessage:@"Invalid credentials"];
            break;

        case NURESTConnectionResponseCodeConflict:
            var responseObject = [[aConnection responseData] JSONObject] || @"Unknown connection error";
            [[self loginWindowController] setMessage:responseObject.errors[0].descriptions[0].title];
            break;

        default:
            [[self loginWindowController] setMessage:@"Unable to connect to the endpoint"];
    }
}

- (void)performLogout
{
    [self performLogoutWithAlert:nil];
}

- (void)performLogoutWithAlert:(CPAlert)anAlert
{
    [self _sendDelegateWillLogout];

    [self _sendLogOutNotification];

    [[self serverFaultWindowController] close];
    [[self mainWindowController] close];
    [[self loginWindowController] showWindow:self];
    [self closeExternalWindows];

    [[NURESTLoginController defaultController] reset];
    [[NURESTPushCenter defaultCenter] stop];

    if (anAlert)
        [anAlert runModal];
}


#pragma mark -
#pragma mark Inspector Management

- (void)openInspectorForSelectedObject
{
    var responder = [[CPApp keyWindow] firstResponder],
        inspectedObject;

    switch ([responder className])
    {
        case @"CPTableView":
            inspectedObject = [[responder dataSource] objectAtIndex:[responder selectedRow]];
            break;

        case @"NUGroupItemTableView":
            inspectedObject = [[[[responder dataSource] content] objectAtIndex:[responder selectedRow]] objectValue];
            break;

        case @"CPOutlineView":
            inspectedObject = [responder itemAtRow:[responder selectedRow]];
            break;

        case @"NUTreeView":
        case @"NUGraphView":
            inspectedObject = [[responder selectedItems] firstObject];
            break;
    }

    [self openInspectorForObject:inspectedObject];
}

- (void)openInspectorForObject:(id)anObject
{
    if (![anObject isKindOfClass:NURESTObject])
        return;

    var inspectedObjectID = [anObject ID];

    if ([NUInspectorWindowController isInspectorOpenedForObjectWithID:inspectedObjectID])
    {
        [[NUInspectorWindowController inspectorForObjectWithID:inspectedObjectID] makeKeyInspector];
        return;
    }

    var inspector = [NUInspectorWindowController new];
    [inspector window];
    [inspector setInspectedObject:anObject];
    [inspector showWindow:self];
}

- (void)registerAdditionalInspectorModuleClass:(Class)aClass cibName:(CPString)aCibName displayDecisionFunction:(Function)aFunction
{
    [NUInspectorWindowController registerAdditionalModuleClass:aClass cibName:aCibName displayDecisionFunction:aFunction];
}


#pragma mark -
#pragma mark Popover Locking

- (void)lockCurrentPopover
{
    var latestWindow = [[CPApp windows] lastObject];

    if ([latestWindow className] != _CPPopoverWindow)
        return;

    _lockedPopover = latestWindow._delegate;

    if (_lockedPopover && [_lockedPopover behavior] == CPPopoverBehaviorTransient)
    {
        var contentView = [[_lockedPopover contentViewController] view];
        [_lockedPopoverView setFrame:[contentView bounds]];
        [contentView addSubview:_lockedPopoverView];

        [_lockedPopover setBehavior:CPPopoverBehaviorApplicationDefined];
    }
}

- (void)unlockCurrentPopover
{
    if (!_lockedPopover)
        return;

    [_lockedPopoverView removeFromSuperview];
    [_lockedPopover setBehavior:CPPopoverBehaviorTransient];
}

@end
