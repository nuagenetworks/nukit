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
@import <AppKit/CPControl.j>
@import <AppKit/CPButton.j>
@import <AppKit/CPBox.j>
@import <AppKit/CPImageView.j>

@import "NUSkin.j"
@import "NUStackView.j"
@import "NUUtilities.j"

@class NUKit


var NUKitToolBarDefault;

/*! NUKitToolBar is a really simple toolbar, way easier to use than the CPToolbar
    It also do a lot less.
*/
@implementation NUKitToolBar : CPControl
{
    @outlet CPImageView     imageApplicationIcon;
    @outlet CPTextField     fieldApplicationName;
    @outlet NUStackView     stackViewButtons;

    CPButton                _buttonLogout       @accessors(property=buttonLogout);

    CPView                  _viewSeparator;
    CPDictionary            _buttonsRegistry;
    CPView                  _viewIcon;
    id                      _applicationNameBoundObject;
    CPString                _applicationNameBoundKeyPath;
    id                      _applicationIconBoundObject;
    CPString                _applicationIconBoundKeyPath;

}


#pragma mark -
#pragma mark Class Methods

/*! Returns the default toolbar
*/
+ (id)defaultToolBar
{
    return NUKitToolBarDefault;
}


#pragma mark -
#pragma mark Initialization

/*! @ignore
*/
- (id)initWithFrame:(CGRect)aFrame
{
    if (self = [super initWithFrame:aFrame])
        [self _init];

    return self;
}

/*! @ignore
*/
- (void)_init
{
    _buttonsRegistry = @{};

    NUKitToolBarDefault = self;

    _buttonLogout = [[CPButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [_buttonLogout setBordered:NO];
    [_buttonLogout setButtonType:CPMomentaryChangeButton];
    [_buttonLogout setValue:NUImageInKit(@"toolbar-logout.png", 32.0, 32.0) forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_buttonLogout setValue:NUImageInKit(@"toolbar-logout-pressed.png", 32.0, 32.0) forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    [_buttonLogout setToolTip:@"Log out from the application"];
    [_buttonLogout setTarget:[NUKit kit]];
    [_buttonLogout setAction:@selector(performLogout)];
    _cucappID(_buttonLogout, @"button-toolbar-logout");

    _viewSeparator = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 1, 32)];
    [_viewSeparator setBackgroundColor:NUSkinColorGrey];
}

/*! @ignore
*/
- (void)awakeFromCib
{
    [stackViewButtons setMode:NUStackViewModeHorizontal];
    [stackViewButtons setMargin:CGInsetMake(0, 5, 0, 5)];

    [self setBackgroundColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"toolbar-background"]];

    [fieldApplicationName setStringValue:[[NUKit kit] companyName]];
    [imageApplicationIcon setImage:[[NUKit kit] companyLogo]];
    [fieldApplicationName setTextColor:[[[NUKit kit] moduleColorConfiguration] objectForKey:@"toolbar-foreground"]];

    _cucappID(fieldApplicationName, @"toolbar-application-name");

    [self setNeedsLayout];
}


#pragma mark -
#pragma mark Utilities

/*! Sets the current enterprise. This is kind of badly named and it will change.
*/
- (void)setCurrentEnterprise:(id)anEnterprise
{
    [_viewIcon setObjectValue:anEnterprise];
}

/*! Register a new button for the given roles.
*/
- (void)registerButton:(CPButton)aButton forRoles:(CPArray)someRoles
{
    [_buttonsRegistry setObject:someRoles || [CPNull null] forKey:aButton];
    [self setNeedsLayout];
}


#pragma mark -
#pragma mark Application Name and Icon Management

/*! Bind the application name field to the given object with the given keypath
*/
- (void)bindApplicationNameToObject:(id)anObject withKeyPath:(CPString)aKeyPath
{
    [fieldApplicationName unbind:CPValueBinding];

    _applicationNameBoundObject = anObject;
    _applicationNameBoundKeyPath = aKeyPath;

    if (anObject)
        [fieldApplicationName bind:CPValueBinding toObject:anObject withKeyPath:aKeyPath options:nil];
    else
        [fieldApplicationName setStringValue:[[NUKit kit] companyName]];
}

/*! Bind the application icon field to the given object with the given keypath
*/
- (void)bindApplicationIconToObject:(id)anObject withKeyPath:(CPString)aKeyPath
{
    [imageApplicationIcon unbind:CPValueBinding];

    _applicationIconBoundObject = anObject;
    _applicationIconBoundKeyPath = aKeyPath;

    if (anObject)
        [imageApplicationIcon bind:CPValueBinding toObject:anObject withKeyPath:aKeyPath options:nil];
    else
        [imageApplicationIcon setImage:[[NUKit kit] companyLogo]];
}

/*! Sets a temporary application name
*/
- (void)setTemporaryApplicationName:(CPString)aName
{
    [fieldApplicationName unbind:CPValueBinding];
    [fieldApplicationName setStringValue:aName];
}

/*! Sets a temporary application icon
*/
- (void)setTemporaryApplicationIcon:(CPString)anIcon
{
    [imageApplicationIcon unbind:CPValueBinding];
    [imageApplicationIcon setImage:anIcon];
}

/*! Resets the temporary application name
*/
- (void)resetTemporaryApplicationName
{
    [self bindApplicationNameToObject:_applicationNameBoundObject withKeyPath:_applicationNameBoundKeyPath];
}

/*! Resets the temporary application icon
*/
- (void)resetTemporaryApplicationIcon
{
    [self bindApplicationIconToObject:_applicationIconBoundObject withKeyPath:_applicationIconBoundKeyPath];
}


#pragma mark -
#pragma mark Layout

/*! @ignore
*/
- (void)layoutSubviews
{
    [super layoutSubviews];

    var buttonsList = [];

    for (var i = 0, c = [[_buttonsRegistry allKeys] count]; i < c; i++)
    {
        var button = [_buttonsRegistry allKeys][i],
            roles = [_buttonsRegistry objectForKey:button];

        if (roles == [CPNull null] || [roles containsObject:[[[NUKit kit] rootAPI] role]])
            [buttonsList addObject:button];
    }

    if ([buttonsList count] > 1)
        [buttonsList addObject:_viewSeparator];

    [buttonsList addObject:_buttonLogout];

    [stackViewButtons setSubviews:buttonsList];

    var frame          = [self frame],
        stackViewFrame = CGRectMakeCopy([stackViewButtons frame]);

    stackViewFrame.origin.x = frame.size.width - stackViewFrame.size.width - 5;
    [stackViewButtons setFrame:stackViewFrame];
}


#pragma mark -
#pragma mark CPCoding compliance

/*! @ignore
*/
- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldApplicationName = [aCoder decodeObjectForKey:@"fieldApplicationName"];
        imageApplicationIcon = [aCoder decodeObjectForKey:@"imageApplicationIcon"];
        stackViewButtons     = [aCoder decodeObjectForKey:@"stackViewButtons"];

        [self _init];
    }

    return self;
}

/*! @ignore
*/
- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldApplicationName forKey:@"fieldApplicationName"];
    [aCoder encodeObject:imageApplicationIcon forKey:@"imageApplicationIcon"];
    [aCoder encodeObject:stackViewButtons forKey:@"stackViewButtons"];
}

@end
