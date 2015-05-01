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
    @outlet CPImageView viewIcon;
    @outlet CPTextField fieldName;

    CPColor             _iconBorderColor @accessors(property=iconBorderColor);
    CPColor             _textColor       @accessors(property=textColor);
}

- (void)bindDataView
{
    [super bindDataView];

    [viewIcon setImage:[[_objectValue class] moduleIcon]];
    [fieldName setStringValue:[[_objectValue class] moduleName]];

    viewIcon._DOMElement.style.boxShadow = @"0 0 0 1px " + [_iconBorderColor cssString];
    [fieldName setTextColor:_textColor];

    _cucappID(self, [[_objectValue class] moduleIdentifier]);

    if (!NUKitParameterShowDebugToolTips)
        [self setToolTip:[[_objectValue class] moduleName]];
}

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldName        = [aCoder decodeObjectForKey:@"fieldName"];
        viewIcon         = [aCoder decodeObjectForKey:@"viewIcon"];
        _iconBorderColor = [aCoder decodeObjectForKey:@"_iconBorderColor"];
        _textColor       = [aCoder decodeObjectForKey:@"textColor"];

        viewIcon._DOMElement.style.borderRadius = @"2px";
        viewIcon._DOMImageElement.style.borderRadius = @"2px";
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldName forKey:@"fieldName"];
    [aCoder encodeObject:viewIcon forKey:@"viewIcon"];
    [aCoder encodeObject:_iconBorderColor forKey:@"_iconBorderColor"];
    [aCoder encodeObject:_textColor forKey:@"_textColor"];
}

@end
