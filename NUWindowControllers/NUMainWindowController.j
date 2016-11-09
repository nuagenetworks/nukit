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
@import <AppKit/CPWindowController.j>
@import <AppKit/CPPopover.j>
@import <Bambou/Bambou.j>
@import "NUDataTransferController.j"
@import "NUKitToolBar.j"
@import "NUModule.j"
@import "NUUtilities.j"

@class NUKit


var NUMainWindowControllerDefault,
    NUMainWindowControllerDefaultBodyBackgound;


@implementation NUMainWindowController : CPWindowController
{
    @outlet CPImageView                         imageViewCurrentUserAvatar;
    @outlet CPImageView                         imageViewPoweredBy;
    @outlet CPTextField                         fieldAboutBuildVersion;
    @outlet CPTextField                         fieldCurrentUser;
    @outlet CPView                              viewFooter;
    @outlet CPView                              viewMainContainer;
    @outlet CPView                              viewTooSmallWindowSize;
    @outlet NUKitToolBar                        toolBar;

    NUModule                                    _coreModule;
    BOOL                                        _ignoreWindowSize;
    CPArray                                     _principalModules;
    NUModule                                    _visiblePrincipalModule;
}

+ (id)defaultController
{
    return NUMainWindowControllerDefault;
}

#pragma mark -
#pragma mark Initialization

- (id)init
{
    if (self = [super initWithWindowCibName:@"MainWindow"])
    {
        NUMainWindowControllerDefault              = self;
        NUMainWindowControllerDefaultBodyBackgound = document.body.style.backgroundImage;
        _principalModules                          = [];
    }

    return self;
}

- (void)windowDidLoad
{
    // CSS Animations And Main Window config
    var mainWindow = [self window],
        DOMWindow = mainWindow._windowView._DOMElement;

    DOMWindow.style.WebkitAnimationDuration  = "0.5s";
    DOMWindow.style.WebkitTransform          = "translateZ(0)";
    DOMWindow.style.WebkitBackfaceVisibility = "hidden";
    DOMWindow.style.WebkitAnimationFillMode  = "forwards";

    DOMWindow.style.MozAnimationDuration     = "0.5s";
    DOMWindow.style.MozTransform             = "translateZ(0)";
    DOMWindow.style.MozBackfaceVisibility    = "hidden";

    DOMWindow.style.animationDuration        = "0.5s";
    DOMWindow.style.transform                = "translateZ(0)";
    DOMWindow.style.backfaceVisibility       = "hidden";

    [mainWindow setFullPlatformWindow:YES];
    [[mainWindow contentView] setBackgroundColor:NUSkinColorGreyLight];

    // Footer
    [fieldAboutBuildVersion setStringValue:[[NUKit kit] copyright]];

    [viewFooter setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"footer-background"]];

    [imageViewCurrentUserAvatar setImageScaling:CPScaleToFit];
    [imageViewCurrentUserAvatar setBackgroundColor:NUSkinColorBlue];
    imageViewCurrentUserAvatar._DOMElement.style.boxShadow = @"0 0 0 1px " + [NUSkinColorGreyLight cssString];
    imageViewCurrentUserAvatar._DOMElement.style.borderRadius = @"2px";
    imageViewCurrentUserAvatar._DOMImageElement.style.borderRadius = @"2px";

    [fieldCurrentUser setTextColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"footer-foreground"]];

    // view too small
    [viewTooSmallWindowSize setBackgroundColor:NUSkinColorGreyLight];
    [viewTooSmallWindowSize setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

    [imageViewPoweredBy setHidden:![[NUKit kit] usesPoweredBy]];
}


#pragma mark -
#pragma mark Modules Management

- (void)registerCoreModule:(NUModule)aModule
{
    if (_coreModule)
        [CPException raise:CPInternalInconsistencyException reason:"NUKit can only have one core module"];

    // force loading the window now
    [self window];

    _coreModule = aModule;

    var moduleView = [_coreModule view];
    [moduleView setFrame:[viewMainContainer bounds]];
    [viewMainContainer addSubview:moduleView];
}

- (void)registerPrincipalModule:(NUModule)aModule accessButton:(CPButton)aButton availableToRoles:(CPArray)someRoles
{
    [_principalModules addObject:aModule];

    [[aModule view] setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [[aModule view] setInAnimation:@"fadeInDown" duration:0.2];
    [[aModule view] setOutAnimation:@"fadeOutUp" duration:0.2];

    [[aModule buttonBack] setTarget:self];
    [[aModule buttonBack] setAction:@selector(switchPrincipalModule:)];
    [[aModule buttonBack] setTag:aModule];

    [aButton setTag:aModule];
    [aButton setTarget:self];
    [aButton setAction:@selector(switchPrincipalModule:)]

    [toolBar registerButton:aButton forRoles:someRoles];
}


#pragma mark -
#pragma mark Utilities

- (void)_manageVisibilityOfWindowSizeWarning
{
    if (_ignoreWindowSize)
    {
        [toolBar setHidden:NO];

        if ([viewTooSmallWindowSize superview])
            [viewTooSmallWindowSize removeFromSuperview];

        return;
    }

    var windowFrame = [[self window] frame],
        width = windowFrame.size.width,
        height = windowFrame.size.height;

    if (width <= 1023 || height <= 300)
    {
        [toolBar setHidden:YES];
        [viewTooSmallWindowSize setFrame:[[self window] frame]];
        [[[self window] contentView] addSubview:viewTooSmallWindowSize];
        [_coreModule closeAllPopovers];
        [[[NUKit kit] registeredDataViewWithIdentifier:@"popoverConfirmation"] close];
    }
    else
    {
        if ([viewTooSmallWindowSize superview])
            [viewTooSmallWindowSize removeFromSuperview];

        [toolBar setHidden:NO];
    }
}

- (void)_showPrincipalModule:(NUModule)aModule withCurrentParent:(NURESTObject)aParent
{
    if (_visiblePrincipalModule)
        [self _hideCurrentPrincipalModule];

    [_coreModule closeAllPopovers];
    
    [[aModule view] setFrame:[viewMainContainer bounds]];
    [viewMainContainer addSubview:[aModule view]];
    _visiblePrincipalModule = aModule;

    [aModule setCurrentParent:aParent];
    [aModule willShow];

    [[NUKitToolBar defaultToolBar] setTemporaryApplicationName:[[aModule class] moduleName]];
    [[NUKitToolBar defaultToolBar] setTemporaryApplicationIcon:[[aModule class] moduleIcon]];
}

- (void)_hideCurrentPrincipalModule
{
    if (!_visiblePrincipalModule)
        return;

    [_visiblePrincipalModule willHide];
    [_visiblePrincipalModule setCurrentParent:nil];
    [[_visiblePrincipalModule view] removeFromSuperview];
    _visiblePrincipalModule = nil;

    [[NUKitToolBar defaultToolBar] resetTemporaryApplicationName];
    [[NUKitToolBar defaultToolBar] resetTemporaryApplicationIcon];
}

- (void)_performWindowAnimation:(CPString)anAnimationName endFunction:(function)aFunction
{
    var DOMWindow = [self window]._windowView._DOMElement;

    DOMWindow.style.WebkitAnimationName      = anAnimationName;
    DOMWindow.style.WebkitAnimationDuration  = "0.5s";
    DOMWindow.style.WebkitTransform          = "translateZ(0)";
    DOMWindow.style.WebkitBackfaceVisibility = "hidden";
    DOMWindow.style.WebkitAnimationFillMode  = "forwards";

    DOMWindow.style.MozAnimationName         = anAnimationName;
    DOMWindow.style.MozAnimationDuration     = "0.5s";
    DOMWindow.style.MozTransform             = "translateZ(0)";
    DOMWindow.style.MozBackfaceVisibility    = "hidden";

    DOMWindow.style.animationName            = anAnimationName;
    DOMWindow.style.animationDuration        = "0.5s";
    DOMWindow.style.transform                = "translateZ(0)";
    DOMWindow.style.backfaceVisibility       = "hidden";

    DOMWindow.addEventListener("webkitAnimationEnd", aFunction, NO);
    DOMWindow.addEventListener("animationend", aFunction, NO);
}


#pragma mark -
#pragma mark Actions

- (@action)logOut:(id)aSender
{
    [[NUKit kit] performLogout];
}

- (@action)switchPrincipalModule:(id)aSender
{
    var module = [aSender tag];

    if (_visiblePrincipalModule == module)
        [self _hideCurrentPrincipalModule];
    else
        [self _showPrincipalModule:module withCurrentParent:[[NUKit kit] rootAPI]];
}

- (@action)ignoreWindowSizeWarning:(id)aSender
{
    _ignoreWindowSize = YES;
    [self _manageVisibilityOfWindowSizeWarning];
    [[self window] setDelegate:nil];
}


#pragma mark -
#pragma mark Overrides

- (@action)showWindow:(id)aSender
{
    if ([[self window] isVisible])
        return;

    [[[NUKit kit] messagesWindowController] hideBlurView];

    [self _performWindowAnimation:@"scaleIn" endFunction:function()
    {
        this.removeEventListener("webkitAnimationEnd", arguments.callee, NO);
        this.removeEventListener("animationend", arguments.callee, NO);

        window.document.body.style.backgroundImage = @"";

        [self _hideCurrentPrincipalModule];
        [self _manageVisibilityOfWindowSizeWarning];

        [_coreModule setCurrentParent:[[NUKit kit] rootAPI]];
        [_coreModule willShow];

        [fieldCurrentUser bind:CPValueBinding toObject:[[NUKit kit] rootAPI] withKeyPath:@"displayDescription" options:nil];
        [imageViewCurrentUserAvatar bind:CPValueBinding toObject:[[NUKit kit] rootAPI] withKeyPath:@"icon" options:nil];

        [[self window] setDelegate:self];
        [[NUKitToolBar defaultToolBar] setNeedsLayout];

        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
    }];

    [super showWindow:aSender];
}

- (void)close
{
    if (![[self window] isVisible])
        return;

    document.body.style.backgroundImage = NUMainWindowControllerDefaultBodyBackgound;

    [self _hideCurrentPrincipalModule];

    [_CPToolTip invalidateCurrentToolTipIfNeeded];

    [[CPNotificationCenter defaultCenter] removeObserver:self name:NURESTPushCenterPushReceived object:[NURESTPushCenter defaultCenter]];

    [_coreModule.tableView deselectAll];
    [_coreModule willHide];
    [_coreModule setCurrentParent:nil];

    [self _performWindowAnimation:@"scaleOut" endFunction:function()
    {
        this.removeEventListener("webkitAnimationEnd", arguments.callee, NO);
        this.removeEventListener("animationend", arguments.callee, NO);

        [super close];

        [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
    }];
}


#pragma mark -
#pragma mark CPWindow Delegate

- (void)windowDidResize:(CPWindow)aWindow
{
    [self _manageVisibilityOfWindowSizeWarning];
}

- (void)windowWillClose:(CPWindow)aWindow
{
    [[NUKit kit] closeExternalWindows];
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
