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
@import "NUModule.j"

@class NUKit

@global CPApp


/*! NUModuleSingleObjectShower is a ready to use module to show one single object
    in a data view in a popover.
    YOU MUST CREATE THIS MODULE PROGRAMMATICALLY using the + (id)new API
*/
@implementation NUModuleSingleObjectShower : NUModule
{
    @outlet CPView      viewContainer;
    @outlet CPButton    buttonOpenInspector;

    CPView              _currentDataView;
    CPView              _targetView;
}


#pragma mark -
#pragma mark Initialization

/*! Creates a new NUModuleSingleObjectShower
*/
+ (id)new
{
    var obj = [[self alloc] initWithCibName:@"SingleObjectShower" bundle:[CPBundle bundleWithIdentifier:@"net.nuagenetworks.nukit"]];

    [obj view];

    return obj;
}

/*! @ignore
*/
+ (CPString)moduleName
{
    return @"No Name";
}

/*! @ignore
*/
- (void)viewDidLoad
{
    [super viewDidLoad];

    [buttonOpenInspector setBordered:NO];
    [buttonOpenInspector setButtonType:CPMomentaryChangeButton];
    [buttonOpenInspector setValue:CPImageInBundle("button-view.png", 16.0, 16.0, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [buttonOpenInspector setValue:CPImageInBundle("button-view-pressed.png", 16.0, 16.0, [[NUKit kit]  bundle]) forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    _cucappID(buttonOpenInspector, @"button-open-inspector");
}


#pragma mark -
#pragma mark Configuration

/*! Fetch the given object and show it in the given dataview in a popover with the given title
*/
- (void)showObject:(id)anObject dataView:(CPView)aDataView view:(id)aView title:(CPString)aTitle
{
    // load view if needed;
    [self view];

    _currentDataView = aDataView;
    _targetView      = aView;

    [_currentDataView setFrameOrigin:CGPointMakeZero()];
    [viewContainer setSubviews:[]];
    [self setModuleTitle:aTitle];
    [anObject fetchAndCallSelector:@selector(_didFetchObject:connection:) ofObject:self];
}

/*! @ignore
*/
- (void)_didFetchObject:(id)anObject connection:(NURESTConnection)aConnection
{
    if (![NURESTConnection handleResponseForConnection:aConnection postErrorMessage:YES])
        return;

    [self setCurrentParent:anObject];
    [_currentDataView setObjectValue:_currentParent];

    var size = [_currentDataView frameSize];
    size.height += 32;

    [viewContainer addSubview:_currentDataView];

    [self setModulePopoverBaseSize:size];
    [self showOnView:_targetView forParentObject:_currentParent];
}


#pragma mark -
#pragma mark Overrides

/*! @ignore
*/
- (@action)openInspector:(id)aSender
{
    [[NUKit kit] openInspectorForObject:_currentParent];
}

/*! @ignore
*/
- (void)_didReceivePush:(CPNotification)aNotification
{
    var JSONObject = [aNotification userInfo],
        events     = JSONObject.events;

    if (events.length <= 0)
        return;

    for (var i = 0, c = events.length; i < c; i++)
    {
        var eventType  = events[i].type,
            entityType = events[i].entityType,
            entityJSON = events[i].entities[0];

        if (entityJSON.ID != [_currentParent ID])
            break;

        switch (eventType)
        {
            case NUPushEventTypeUpdate:
                [_currentParent objectFromJSON:entityJSON];
                break;

            case NUPushEventTypeRevoke:
            case NUPushEventTypeDelete:
                [_modulePopover close];
                break;
        }
    }
}

@end
