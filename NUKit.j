/*
* Copyright (c) 2016, Alcatel-Lucent Inc
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the copyright holder nor the names of its contributors
*       may be used to endorse or promote products derived from this software without
*       specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

@import <Foundation/Foundation.j>

@import "NUAssociators.j"
@import "NUCategories.j"
@import "NUControls.j"
@import "NUDataSources.j"
@import "NUDataViews.j"
@import "NUDataViewsLoaders.j"
@import "NUHierarchyControllers.j"
@import "NUModels.j"
@import "NUModules.j"
@import "NUSkins.j"
@import "NUTransformers.j"
@import "NUUtils.j"
@import "NUWindowControllers.j"


var NUKitDefaultKit ,
    NUKitDataViewsRegistryDataViewsRegistry = @{},
    NUKitDelegate_didLogin_             = 1 << 1,
    NUKitDelegate_willLogout_           = 1 << 2,
    NUKitDelegate_shouldLogin_          = 1 << 3,
    NUKitDelegate_improperLoginReason_  = 1 << 4,
    NUKitDelegate_shouldLogout_         = 1 << 5,
    NUKitDelegate_improperLogoutReason_ = 1 << 6;

NUKitUserLoggedInNotification      = @"NUKitUserLoggedInNotification";
NUKitUserLoggedOutNotification     = @"NUKitUserLoggedOutNotification";

NUKitParameterShowDebugToolTips    = NO;
NUKitParameterCat                  = NO;
NUKitParameterExperimentalMode     = NO;
NUKitParameterVeryExperimentalMode = NO;

NUPermissionLevelAdmin             = @"admin";
NUPermissionLevelAdminOperator     = @"adminoperator"
NUPermissionLevelOperator          = @"operator";
NUPermissionLevelPowerUser         = @"poweruser";
NUPermissionLevelRoot              = @"root";
NUPermissionLevelSecurityAdmin     = @"securityadmin"
NUPermissionLevelSystem            = @"system";
NUPermissionLevelUser              = @"user";


function nukit_set_permission_level_system_value(value) {
    NUPermissionLevelSystem = value;
}

function nukit_set_permission_level_root_value(value) {
    NUPermissionLevelRoot = value;
}

function nukit_set_permission_level_operator_value(value) {
    NUPermissionLevelOperator = value;
}

function nukit_set_permission_level_admin_value(value) {
    NUPermissionLevelAdmin = value;
}

function nukit_set_permission_level_power_user_value(value) {
    NUPermissionLevelPowerUser = value;
}

function nukit_set_permission_level_user_value_value(value) {
    NUPermissionLevelUser = value;
}

function nukit_set_permission_level_adminoperator_value_value(value) {
    NUPermissionLevelAdminOperator = value;
}

function nukit_set_permission_level_securityadmin_value_value(value) {
    NUPermissionLevelSecurityAdmin = value;
}

@implementation NUKit : CPObject
{
    BOOL                            _usesPoweredBy                  @accessors(property=usesPoweredBy);
    CPBundle                        _bundle                         @accessors(getter=bundle);
    CPDictionary                    _moduleColorConfiguration       @accessors(property=moduleColorConfiguration);
    CPImage                         _applicationLogo                @accessors(property=applicationLogo);
    CPImage                         _companyLogo                    @accessors(property=companyLogo);
    CPString                        _APIPrefix                      @accessors(property=APIPrefix);
    CPString                        _applicationName                @accessors(property=applicationName);
    CPString                        _autoServerBaseURL              @accessors(property=autoServerBaseURL);
    CPString                        _companyName                    @accessors(property=companyName);
    CPString                        _copyright                      @accessors(property=copyright);
    id                              _rootAPI                        @accessors(property=rootAPI);
    NULoginWindowController         _loginWindowController          @accessors(getter=loginWindowController);
    NUMainWindowController          _mainWindowController           @accessors(property=mainWindowController);
    NUMessagesWindowController      _messagesWindowController       @accessors(getter=messagesWindowController);
    NUServerFaultWindowController   _serverFaultWindowController    @accessors(getter=serverFaultWindowController);

    BOOL                            _isAppClosing;
    CPArray                         _sharedModules;
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
        _moduleColorConfiguration = @{
            @"main-view-background": NUSkinColorGreyLighter,
            @"tableview-view-background": NUSkinColorWhite,
            @"masking-view-background": NUSkinColorGreyLighter,

            @"title-container-view-background": NUSkinColorGreyLight,
            @"title-field-foreground": NUSkinColorBlack,

            @"subtitle-container-view-background": NUSkinColorGreyLight,
            @"subtitle-field-foreground": NUSkinColorBlack,

            @"total-entities-field-foreground": NUSkinColorBlack,
            @"total-entities-field-background": NUSkinColorGreyLighter,

            @"edition-popover-title-foreground": NUSkinColorBlue,

            @"moddule-popover-title-field-foreground": NUSkinColorWhite,
            @"module-popover-title-view-background": NUSkinColorBlack,

            @"editor-container-view-background": NUSkinColorGreyLight,
            @"editor-container-shadow-color": NUSkinColorGrey,

            @"main-table-view-container-background": NUSkinColorGreyLight,

            @"toolbar-background": NUSkinColorGreyLight,
            @"toolbar-foreground": NUSkinColorBlack,

            @"footer-background": NUSkinColorGreyLight,
            @"footer-foreground": NUSkinColorBlack,

            @"chooser-popover-banner-background": NUSkinColorBlack,
            @"chooser-popover-banner-foreground": NUSkinColorWhite,
        }

        _bundle = [CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"];

        [self installStyleSheetOnDocument:document];

        _APIPrefix                   = @"api/";
        _sharedModules               = @{};

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
    [[[NUInternalDataViewsLoader alloc] initWithCibName:@"DataViews" bundle:[self bundle]] load];
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

- (void)registerPrincipalModule:(NUModule)aModule withButtonImage:(CPImage)anImage altImage:(CPImage)anAltImage toolTip:(CPString)aToolTip identifier:(CPString)anIdentifier availableToRoles:(CPArray)someRoles
{
    var button = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [button setBordered:NO];
    [button setButtonType:CPMomentaryChangeButton];
    [button setValue:anImage forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [button setValue:anAltImage forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    [button setToolTip:aToolTip];
    _cucappID(button, anIdentifier);

    [self registerPrincipalModule:aModule accessButton:button availableToRoles:someRoles];

}

- (void)registerPrincipalModule:(NUModule)aModule accessButton:(CPButton)aButton availableToRoles:(CPArray)someRoles
{
    [_mainWindowController registerPrincipalModule:aModule accessButton:aButton availableToRoles:someRoles];
}

- (void)configureContextDefaultFirstResponderTags:(CPArray)anArray
{
    [NUModuleContext setDefaultFirstResponderTags:anArray];
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
    [[self loginWindowController] setButtonLoginEnabled:YES];
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

- (id)valueForApplicationArgument:(CPString)aString
{
   if (window.location.search.indexOf(aString) == -1)
       return nil;

   return _get_query_parameter_with_name(aString) || YES;
}

- (CPString)stringValueForApplicationArgument:(CPString)aString
{
    var value = [self valueForApplicationArgument:aString];

    return [value isKindOfClass:CPString] && [value length] ? value : nil;
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
}


#pragma mark -
#pragma mark Shared Modules Management

- (void)registerSharedModule:(NUModule)aSharedModule withIdentifier:(CPString)anIdentifier
{
    if (![_sharedModules containsKey:anIdentifier])
        [_sharedModules setObject:aSharedModule forKey:anIdentifier];
}

- (NUModule)sharedModuleWithIdentifier:(CPString)anIdentifier
{
    return [_sharedModules objectForKey:anIdentifier];
}


#pragma mark -
#pragma mark Data View Management

- (void)registerDataView:(NUAsbtractDataView)aDataView withIdentifier:(CPString)aName
{
    if (![NUKitDataViewsRegistryDataViewsRegistry containsKey:aName])
        [NUKitDataViewsRegistryDataViewsRegistry setObject:aDataView forKey:aName];
}

- (id)registeredDataViewWithIdentifier:(CPString)aName
{
    return [NUKitDataViewsRegistryDataViewsRegistry objectForKey:aName];
}


#pragma mark -
#pragma mark External Platform Windows Management

- (void)closeExternalWindows
{
    [CPPlatform closeAllPlatformWindows];
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

    if ([_delegate respondsToSelector:@selector(applicationShouldLogin:)])
        _implementedDelegateMethods |= NUKitDelegate_shouldLogin_;

    if ([_delegate respondsToSelector:@selector(applicationShouldLogin:)])
        _implementedDelegateMethods |= NUKitDelegate_shouldLogin_;

    if ([_delegate respondsToSelector:@selector(applicationImproperLoginReason:)])
        _implementedDelegateMethods |= NUKitDelegate_improperLoginReason_;

    if ([_delegate respondsToSelector:@selector(applicationShouldLogout:)])
        _implementedDelegateMethods |= NUKitDelegate_shouldLogout_;

    if ([_delegate respondsToSelector:@selector(applicationImproperLogoutReason:)])
        _implementedDelegateMethods |= NUKitDelegate_improperLogoutReason_;
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

- (BOOL)_sendDelegateShouldLogin
{
    if (_implementedDelegateMethods & NUKitDelegate_shouldLogin_)
        return [_delegate applicationShouldLogin:self];

    return YES;
}

- (CPString)_sendDelegateImproperLoginReason
{
    if (_implementedDelegateMethods & NUKitDelegate_improperLoginReason_)
        return [_delegate applicationImproperLoginReason:self];
}

- (BOOL)_sendDelegateShouldLogout
{
    if (_implementedDelegateMethods & NUKitDelegate_shouldLogout_)
        return [_delegate applicationShouldLogout:self];

    return YES;
}

- (CPString)_sendDelegateImproperLogoutReason
{
    if (_implementedDelegateMethods & NUKitDelegate_improperLogoutReason_)
        return [_delegate applicationImproperLogoutReason:self];
}


#pragma mark -
#pragma mark REST URL Management

- (CPURL)RESTBaseURL
{
    var baseURLString   = [[CPUserDefaults standardUserDefaults] objectForKey:@"NUAPIURL"],
        baseURL         = [CPURL URLWithString:baseURLString[baseURLString.length - 1] != @"/" ? baseURLString + @"/" : baseURLString],
        APIVersion      = @"v" + [[CPBundle mainBundle] objectForInfoDictionaryKey:@"NUAPIVersion"].replace(".", "_"),
        finalRESTURL;

    var customAPIVersion = [self valueForApplicationArgument:@"apiversion"];
    if (customAPIVersion)
        APIVersion = customAPIVersion;

    if (baseURL == @"auto/")
        baseURL = [CPURL URLWithString:[self _discoverServerURL] + @"/"];

    finalRESTURL = [CPURL URLWithString:(_APIPrefix + APIVersion + "/") relativeToURL:baseURL];

    CPLog.info("REST URL base is set to %@", finalRESTURL);

    return finalRESTURL;
}

- (CPString)_discoverServerURL
{
    if (!_autoServerBaseURL || _autoServerBaseURL == "")
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
    else
        return _autoServerBaseURL;
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
    var userInfo = [self stringValueForApplicationArgument:@"userinfo"],
        user     = [self stringValueForApplicationArgument:@"user"],
        org      = [self stringValueForApplicationArgument:@"org"],
        pass     = [self stringValueForApplicationArgument:@"pass"],
        api      = [self stringValueForApplicationArgument:@"api"] || @"auto";

    if (userInfo && api && org)
        [self performAutoLoginWithUserInfo:userInfo organization:org url:api];
    else if (user && org && pass && api)
        [self performLoginWithUserName:user organization:org password:pass url:api];
    else
        [[self loginWindowController] showWindow:self];
}

- (void)_continueLogin
{
    [[NURESTLoginController defaultController] setAPIKey:[[self rootAPI] APIKey]];
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

    [[self rootAPI] setID:nil];
    [[self rootAPI] fetchAndCallSelector:@selector(_didFetchUser:connection:) ofObject:self];
}

- (void)performAutoLoginWithUserInfo:(CPString)someUserInfo organization:(CPString)anOrganization url:(CPString)anURL
{
    [[CPUserDefaults standardUserDefaults] setObject:anURL forKey:@"NUAPIURL"];

    var URL      = [self RESTBaseURL],
        JSONinfo = JSON.parse(atob(someUserInfo));

    [[self rootAPI] objectFromJSON:JSONinfo];

    [[NURESTLoginController defaultController] setUser:[[self rootAPI] userName]];
    [[NURESTLoginController defaultController] setCompany:anOrganization];
    [[NURESTLoginController defaultController] setPassword:nil];
    [[NURESTLoginController defaultController] setURL:URL];
    [[NURESTLoginController defaultController] setAPIKey:[[self rootAPI] APIKey]];

    if ([self _sendDelegateShouldLogin])
        [self _continueLogin];
}

- (void)_didFetchUser:(id)anUser connection:(NURESTConnection)aConnection
{
    [[NURESTLoginController defaultController] setPassword:nil];

    switch ([aConnection responseCode])
    {
        case NURESTConnectionResponseCodeSuccess:
            if ([self _sendDelegateShouldLogin])
                [self _continueLogin];
            else
            {
                [[self loginWindowController] shakeWindow];
                [[self loginWindowController] setMessage:[self _sendDelegateImproperLoginReason]];
            }
            break;

        case NURESTConnectionResponseCodeNotFound:
            [[self loginWindowController] shakeWindow];
            [[self loginWindowController] setMessage:@"Resource not found"];
            break;

        case NURESTConnectionResponseCodeUnauthorized:
            [[self loginWindowController] shakeWindow];
            [[self loginWindowController] setMessage:@"Invalid credentials"];
            break;

        case NURESTConnectionResponseCodeConflict:
            [[self loginWindowController] shakeWindow];
            var responseObject = [[aConnection responseData] JSONObject] || @"Unknown connection error";
            [[self loginWindowController] setMessage:responseObject.errors[0].descriptions[0].title];
            break;

        default:
            [[self loginWindowController] shakeWindow];
            [[self loginWindowController] setMessage:@"Unable to connect to the endpoint"];
    }

    [[self loginWindowController] setButtonLoginEnabled:YES];
}

- (void)performLogout
{
    if ([self _sendDelegateShouldLogout])
        [self performLogoutWithAlert:nil];
    else
        alert([self _sendDelegateImproperLogoutReason])
}

- (void)performLogoutWithAlert:(CPAlert)anAlert
{
    [self _sendDelegateWillLogout];

    [self _sendLogOutNotification];

    [[self serverFaultWindowController] close];
    [[self mainWindowController] close];
    [[self loginWindowController] showWindow:self];
    [self unlockCurrentPopover];
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
        case @"OSMMapView":
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
