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
@import <AppKit/CPImageView.j>
@import <AppKit/CPView.j>

@import "NUAbstractDataView.j"


@implementation NUTemplatableObjectDataView : NUAbstractDataView
{
    @outlet CPImageView     imageViewIcon;
    @outlet CPView          viewTemplate;

    BOOL                    _fixedBackgroundColor    @accessors(property=fixedBackgroundColor);
}


#pragma mark -
#pragma mark Data View Protocol

- (void)bindDataView
{
    [super bindDataView];

    if (imageViewIcon)
        [imageViewIcon setImage:[self objectValueisTemplate] ? [self templateIcon] : [self instanceIcon]]

    [self _updateBackground];
}

- (void)_updateBackground
{
    if ([self objectValueIsFromTemplate])
    {
        [viewTemplate setHidden:NO];
        if (![self hasThemeState:CPThemeStateSelectedDataView] && !_fixedBackgroundColor)
            [self setBackgroundColor:NUSkinColorGreyLight];
    }
    else
    {
        [viewTemplate setHidden:YES];

        if (!_fixedBackgroundColor)
            [self setBackgroundColor:nil];
    }
}

- (void)resetBackgroundColor
{
    [self _updateBackground];
}

- (BOOL)objectValueIsFromTemplate
{
    return [_objectValue isFromTemplate];
}

- (BOOL)objectValueisTemplate
{
    return [_objectValue isTemplate];
}

- (CPImage)templateIcon
{
    return nil;
}

- (CPImage)instanceIcon
{
    return nil;
}


#pragma mark -
#pragma mark Overrides

- (BOOL)setThemeState:(ThemeState)aThemeState
{
    aThemeState = _massageThemeState(aThemeState);

    if ([self hasThemeState:aThemeState])
        return;

    [super setThemeState:aThemeState];

    if (aThemeState.hasThemeState(CPThemeStateSelectedDataView))
        [self setBackgroundColor:nil];
}

- (BOOL)unsetThemeState:(ThemeState)aThemeState
{
    aThemeState = _massageThemeState(aThemeState);

    if (![self hasThemeState:aThemeState])
        return;

    [super unsetThemeState:aThemeState];

    if (aThemeState.hasThemeState(CPThemeStateSelectedDataView))
        [self _updateBackground];
}


#pragma mark -
#pragma mark CPCoding compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        imageViewIcon         = [aCoder decodeObjectForKey:@"imageViewIcon"];
        viewTemplate          = [aCoder decodeObjectForKey:@"viewTemplate"];
        _fixedBackgroundColor = [aCoder decodeBoolForKey:@"_fixedBackgroundColor"];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeBool:_fixedBackgroundColor forKey:@"_fixedBackgroundColor"];
    [aCoder encodeObject:imageViewIcon forKey:@"imageViewIcon"];
    [aCoder encodeObject:viewTemplate forKey:@"viewTemplate"];
}

@end
