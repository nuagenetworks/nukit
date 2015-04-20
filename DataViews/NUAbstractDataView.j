/*
*   Filename:         NUAbstractDataView.j
*   Created:          Tue Oct  9 11:54:55 PDT 2012
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
@import <AppKit/CPCheckBox.j>
@import <AppKit/CPColor.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPProgressIndicator.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPView.j>
@import <RESTCappuccino/NURESTObject.j>

@import "../UtilsNUUtilities.j"
@import "../Skins/NUSkin.j"

@global NUGeneralShowDebugToolTips
@global NUNullDescriptionTransformer


@implementation NUAbstractDataView : CPView
{
    BOOL            _enableAutoColor    @accessors(property=enableAutoColor);
    BOOL            _relatedDataView    @accessors(property=relatedDataView);
    id              _objectValue        @accessors(property=objectValue);

    CPView          _markerView;
    CPArray         _innerTextFieldsCache;
}


#pragma mark -
#pragma mark Initialization

- (void)_init
{
    _enableAutoColor      = YES;
    _innerTextFieldsCache = [];

    [self setAutoresizingMask:CPViewNotSizable];
    [self _cacheColoredControls];
}

- (void)_cacheColoredControls
{
    var subviews = [self subviews];

    for (var i = [subviews count] - 1; i >= 0; i--)
    {
        var view = subviews[i];

        if (([view isKindOfClass:CPTextField] && ![view isBezeled]) || [view isKindOfClass:CPCheckBox])
        {
            [_innerTextFieldsCache addObject:view];
            [view setValue:NUSkinColorWhite forThemeAttribute:@"text-color" inState:CPThemeStateSelectedDataView];
        }
    }
}


#pragma mark -
#pragma mark Data View API

- (void)setObjectValue:(id)anObject
{
    if (_objectValue === anObject)
        return;

    _objectValue = anObject;

    if (_objectValue)
    {
        [self _defineCucappIndentifier];
        [self _defineDebugToolTips];
        [self _showExternalObjectMarker];
        [self bindDataView];
    }
    else
    {
        [self unbindDataView];
    }
}


#pragma mark -
#pragma mark Bindings

- (void)bindDataView
{
}

- (void)unbindDataView
{
    [CPBinder unbindAllForObject:self];

    var superclass = [self class];

    while (superclass && [superclass class] != [NUAbstractDataView class])
    {
        var ivars = class_copyIvarList(superclass);

        for (var i = [ivars count] - 1; i >= 0; i--)
            [CPBinder unbindAllForObject:self[ivars[i].name]];

        superclass = [superclass superclass];
    }
}


#pragma mark -
#pragma mark Utilities

- (void)setRelatedDataView:(BOOL)isRelated
{
    if (_relatedDataView === isRelated)
        return;

    _relatedDataView = isRelated;

    if (!_enableAutoColor)
        return;

    if (_relatedDataView && ![self hasThemeState:CPThemeStateSelectedDataView])
        [self setBackgroundColor:NUSkinColorBluePale];
    else
        [self resetBackgroundColor];
}

- (void)setControlsHidden:(BOOL)shouldHide
{
}


#pragma mark -
#pragma mark Auto Coloring

- (void)setEnableAutoColor:(BOOL)shouldEnable
{
    if (_enableAutoColor == shouldEnable)
        return;

    _enableAutoColor = shouldEnable;

    [self _updateCachedControlsTheming];

    if (!_enableAutoColor)
        [_innerTextFieldsCache makeObjectsPerformSelector:@selector(unsetThemeState:) withObject:CPThemeStateSelectedDataView];
}

- (void)_updateCachedControlsTheming
{
    if (!_enableAutoColor)
        return;

    if ([self hasThemeState:CPThemeStateSelectedDataView])
    {
        [self resetBackgroundColor];
        [_innerTextFieldsCache makeObjectsPerformSelector:@selector(setThemeState:) withObject:CPThemeStateSelectedDataView];
    }
    else
    {
        if (_relatedDataView)
            [self setBackgroundColor:NUSkinColorBluePale];
        else
            [self resetBackgroundColor];

        [_innerTextFieldsCache makeObjectsPerformSelector:@selector(unsetThemeState:) withObject:CPThemeStateSelectedDataView];
    }
}

- (void)resetBackgroundColor
{
    [self setBackgroundColor:nil];
}


#pragma mark -
#pragma mark Debug ToolTips

- (void)_defineDebugToolTips
{
    if (!NUGeneralShowDebugToolTips || !_objectValue || ![_objectValue isKindOfClass:NURESTObject])
        return;

    var toolTip = @"";

    toolTip += "cucappID: " + [self cucappIdentifier] + "\n";
    toolTip += @"Object ID: " + [_objectValue ID] + "\n",
    toolTip += @"Object Owner: " + [_objectValue owner] + "\n",
    toolTip += @"Object Parent ID: " + [_objectValue parentID] + "\n",
    toolTip += @"Object Class Name: " + [_objectValue className] + "\n",
    toolTip += "DataView Class Name: " + [self className];

    if ([toolTip length])
        [self setToolTip:toolTip];
}


#pragma mark -
#pragma mark Cucapp

- (void)_defineCucappIndentifier
{
    if ([_objectValue respondsToSelector:@selector(name)] && [_objectValue name])
        _cucappID(self, [_objectValue name]);
    else
        _cucappID(self, [_objectValue description] || [_objectValue UID]);

    [self defineAdditionCucappIdentifier];
}

- (void)defineAdditionCucappIdentifier
{

}


#pragma mark -
#pragma mark Theming

- (BOOL)setThemeState:(ThemeState)aThemeState
{
    aThemeState = _massageThemeState(aThemeState);

    if ([self hasThemeState:aThemeState])
        return;

    [super setThemeState:aThemeState];

    [self _updateCachedControlsTheming];
}

- (BOOL)unsetThemeState:(ThemeState)aThemeState
{
    aThemeState = _massageThemeState(aThemeState);

    if (![self hasThemeState:aThemeState])
        return;

    [super unsetThemeState:aThemeState];

    [self _updateCachedControlsTheming];
}

- (void)_showExternalObjectMarker
{
    var shouldShow = [_objectValue respondsToSelector:@selector(externalID)] && !![_objectValue externalID];

    if (!_markerView)
    {
        _markerView = [[CPView alloc] initWithFrame:CGRectMakeZero()];
        [_markerView setBackgroundColor:NUSkinColorOrange];
        [_markerView setAutoresizingMask:CPViewHeightSizable | CPViewMinXMargin];
    }

    if (shouldShow)
    {
        var frame = CGRectMakeCopy([self frame]);
        frame.size.width = 4.0;
        frame.size.height -= 2;
        frame.origin.y = 1;
        frame.origin.x = [self frame].size.width - frame.size.width;
        [_markerView setFrame:frame];
        [_markerView setToolTip:@"This object is managed by an external solution. Removing or editing is permitted but can be harmful."]
        [self addSubview:_markerView positioned:CPWindowBelow relativeTo:nil];
    }
    else
    {
        [_markerView removeFromSuperview];
    }
}


#pragma mark -
#pragma mark Supports for being in a menu

- (void)highlight:(BOOL)shouldHighlight
{
    if (shouldHighlight)
    {
        [self setBackgroundColor:NUSkinColorBlue];
        [self setThemeState:CPThemeStateSelectedDataView];
    }
    else
    {
        [self resetBackgroundColor];
        [self unsetThemeState:CPThemeStateSelectedDataView];
    }
}


#pragma mark -
#pragma mark CPCoding Compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
        [self _init];

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];
}

@end
