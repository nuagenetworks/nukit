/*
*   Filename:         NUModuleItemizedDataView.j
*   Created:          Wed Oct 15 13:22:59 PDT 2014
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
