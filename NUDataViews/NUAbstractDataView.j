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
@import <AppKit/CPButton.j>
@import <AppKit/CPCheckBox.j>
@import <AppKit/CPColor.j>
@import <AppKit/CPImageView.j>
@import <AppKit/CPProgressIndicator.j>
@import <AppKit/CPTextField.j>
@import <AppKit/CPView.j>
@import <Bambou/NURESTObject.j>

@import "NUUtilities.j"
@import "NUSkin.j"

@global NUKitParameterShowDebugToolTips
@global NUNullDescriptionTransformer


@implementation NUAbstractDataView : CPView
{
    BOOL            _highlighted        @accessors(property=highlighted);
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
    _highlighted          = NO;
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

    if (anObject === nil)
        [self unbindDataView];

    _objectValue = anObject;

    [self resetBackgroundColor];

    if (_objectValue)
    {
        [self _defineCucappIndentifier];
        [self _defineDebugToolTips];
        [self _showExternalObjectMarker];
        [self bindDataView];
    }
}

- (int)computedHeightForObjectValue:(id)anObjectValue
{
    return [self frameSize].height;
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

- (void)setHighlighted:(BOOL)shouldHighlight
{
    _highlighted = shouldHighlight;
    [self _updateTheming];
}


#pragma mark -
#pragma mark Auto Coloring

- (void)setEnableAutoColor:(BOOL)shouldEnable
{
    if (_enableAutoColor == shouldEnable)
        return;

    _enableAutoColor = shouldEnable;

    [self _updateTheming];

    if (!_enableAutoColor)
        [_innerTextFieldsCache makeObjectsPerformSelector:@selector(unsetThemeState:) withObject:CPThemeStateSelectedDataView];
}

- (void)_updateTheming
{
    if (!_enableAutoColor)
        return;

    if ([self hasThemeState:CPThemeStateSelectedDataView])
    {
        if (_highlighted)
            [self setBackgroundColor:NUSkinColorBlue];
        else
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
    if (!NUKitParameterShowDebugToolTips || !_objectValue || ![_objectValue isKindOfClass:NURESTObject])
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

    [self defineAdditionalCucappIdentifier];
}

- (void)defineAdditionalCucappIdentifier
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

    [self _updateTheming];
}

- (BOOL)unsetThemeState:(ThemeState)aThemeState
{
    aThemeState = _massageThemeState(aThemeState);

    if (![self hasThemeState:aThemeState])
        return;

    [super unsetThemeState:aThemeState];

    [self _updateTheming];
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


// Antoine says 8 / 10 it's not used... we'll see in a couple of months (9/25/2015)
// #pragma mark -
// #pragma mark Supports for being in a menu
//
// - (void)highlight:(BOOL)shouldHighlight
// {
//     if (shouldHighlight)
//     {
//         [self setBackgroundColor:NUSkinColorBlue];
//         [self setThemeState:CPThemeStateSelectedDataView];
//     }
//     else
//     {
//         [self resetBackgroundColor];
//         [self unsetThemeState:CPThemeStateSelectedDataView];
//     }
// }


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
