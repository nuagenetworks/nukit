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
@import @"NUAbstractDataView.j"

@global NUKitParameterShowDebugToolTips


@implementation NUItemizedModuleDataView : NUAbstractDataView
{
    @outlet CPImageView imageViewChildren;
    @outlet CPImageView viewIcon;
    @outlet CPTextField fieldName;

    CPColor             _iconBorderColor                @accessors(property=iconBorderColor);
    CPColor             _textColor                      @accessors(property=textColor);
    CPColor             _selectedTextColor              @accessors(property=selectedTextColor);
}

- (void)bindDataView
{
    [super bindDataView];

    [viewIcon setImage:[[[_objectValue module] class] moduleIcon]];
    [fieldName setStringValue:[[[_objectValue module] class] moduleName]];

    viewIcon._DOMElement.style.boxShadow = @"0 0 0 1px " + [_iconBorderColor cssString];
    [fieldName setTextColor:_textColor];

    _cucappID(self, [[[_objectValue module] class] moduleIdentifier]);

    if (!NUKitParameterShowDebugToolTips)
        [self setToolTip:[[[_objectValue module] class] moduleName]];

    [imageViewChildren setHidden:![[_objectValue children] count]]
}


#pragma mark -
#pragma mark Theming

- (BOOL)setThemeState:(ThemeState)aThemeState
{
    aThemeState = _massageThemeState(aThemeState);

    if ([self hasThemeState:aThemeState])
        return;

    [super setThemeState:aThemeState];

    if ([self hasThemeState:CPThemeStateSelectedDataView])
        [fieldName setTextColor:_selectedTextColor];
}

- (BOOL)unsetThemeState:(ThemeState)aThemeState
{
    aThemeState = _massageThemeState(aThemeState);

    if (![self hasThemeState:aThemeState])
        return;

    [super unsetThemeState:aThemeState];

    if (![self hasThemeState:CPThemeStateSelectedDataView])
        [fieldName setTextColor:_textColor];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldName                  = [aCoder decodeObjectForKey:@"fieldName"];
        imageViewChildren          = [aCoder decodeObjectForKey:@"imageViewChildren"];
        viewIcon                   = [aCoder decodeObjectForKey:@"viewIcon"];
        _iconBorderColor           = [aCoder decodeObjectForKey:@"_iconBorderColor"];
        _selectedTextColor         = [aCoder decodeObjectForKey:@"_selectedTextColor"];
        _textColor                 = [aCoder decodeObjectForKey:@"textColor"];

        viewIcon._DOMElement.style.borderRadius = @"2px";
        viewIcon._DOMImageElement.style.borderRadius = @"2px";
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldName forKey:@"fieldName"];
    [aCoder encodeObject:imageViewChildren forKey:@"imageViewChildren"];
    [aCoder encodeObject:viewIcon forKey:@"viewIcon"];
    [aCoder encodeObject:_iconBorderColor forKey:@"_iconBorderColor"];
    [aCoder encodeObject:_selectedTextColor forKey:@"_selectedTextColor"];
    [aCoder encodeObject:_textColor forKey:@"_textColor"];
}

@end



@implementation _NUModuleItemizedSeparatorDataView : CPView

+ (id)newWithColor:(CPColor)aColor
{
    var sep = [[_NUModuleItemizedSeparatorDataView alloc] initWithFrame:CGRectMake(0, 0, 100, 10)],
        line = [[CPView alloc] initWithFrame:CGRectMake(5, 5, 90, 1)];

    [line setBackgroundColor:aColor];
    [line setAutoresizingMask:CPViewWidthSizable];
    [sep addSubview:line];

    return sep;
}

- (void)setObjectValue:(id)aValue
{

}

@end
