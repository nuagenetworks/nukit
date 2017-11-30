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
@import <TNKit/TNTabView.j>

@import "NUSkin.j"
@import "NUUtilities.j"


/*! @ignore
*/
@implementation NUTabViewItemPrototype : TNTabItemPrototype

+ (float)margin
{
    return 40.0;
}

- (void)setTabViewItem:(CPTabViewItem)anItem
{
    if (!anItem)
        return;

    if (anItem._tooltip)
        [self._button setToolTip: anItem._tooltip];
        
    _cucappID(self._button, anItem._cucappID);
        
    [super setTabViewItem:anItem];
}

@end


/*! @ignore
*/
@implementation NUImageTabViewItemPrototype : TNTabItemPrototype
{
    CPImage _image;
    CPImage _imageHighlighted;
    CPImage _imageSelected;
}

#pragma mark -
#pragma mark Class Methods

+ (TNTabItemPrototype)new
{
    return [[self alloc] initWithFrame:CGRectMake(0.0, 0.0, [self size].width, [self size].height)];
}

+ (BOOL)isImage
{
    return YES;
}

+ (CGSize)size
{
    return CGSizeMake(16, 16);
}

+ (float)margin
{
    return 20.0;
}

- (void)prepareTheme
{
    [super prepareTheme];
    [_button setButtonType:CPMomentaryChangeButton];
}

- (void)setTabViewItem:(CPTabViewItem)anItem
{
    if (!anItem)
        return;

    _image = anItem._icon;
    _imageHighlighted = anItem._iconHighlighted;
    _imageSelected = anItem._iconSelected;

    [_button setToolTip:anItem._tooltip]
    [_button setValue:_image forThemeAttribute:@"image" inState:CPThemeStateNormal];
    [_button setValue:_imageHighlighted forThemeAttribute:@"image" inState:CPThemeStateHighlighted];
    _cucappID(_button, anItem._cucappID);

    _tabViewItem = anItem;
}

- (BOOL)setThemeState:(ThemeState)aThemeState
{
    if (aThemeState.hasThemeState(TNTabItemPrototypeThemeStateSelected))
        [_button setValue:_imageSelected forThemeAttribute:@"image" inState:CPThemeStateNormal];

    [_button setThemeState:aThemeState];

    return YES;
}

/*! used to unset theme state of subviews
    @param aThemeState the theme state
*/
- (BOOL)unsetThemeState:(ThemeState)aThemeState
{
    if (aThemeState.hasThemeState(TNTabItemPrototypeThemeStateSelected))
        [_button setValue:_image forThemeAttribute:@"image" inState:CPThemeStateNormal];

    [_button unsetThemeState:aThemeState];

    return YES;
}

@end
