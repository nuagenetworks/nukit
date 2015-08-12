/*
*   Filename:         NULibraryItemDataView.j
*   Created:          Fri Jun 21 11:08:37 PDT 2013
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
@import "NUAbstractDataView.j"


@implementation NULibraryItemDataView : NUAbstractDataView
{
    @outlet CPTextField     fieldName;
    @outlet CPTextField     fieldDescription;
    @outlet CPImageView     imageViewIcon;
}


#pragma mark -
#pragma mark Data View Protocol

- (void)setObjectValue:(id)anObject
{
    _objectValue = anObject;

    [fieldName bind:CPValueBinding toObject:anObject withKeyPath:@"name" options:nil];
    [fieldDescription bind:CPValueBinding toObject:anObject withKeyPath:@"description" options:nil];
    [imageViewIcon bind:CPValueBinding toObject:anObject withKeyPath:@"icon" options:nil];

    _cucappID(self, [_objectValue name]);
}

#pragma mark -
#pragma mark Overrides

- (void)draggingImageView
{
    var enclosingView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)],
        view = [[CPView alloc] initWithFrame:CGRectMake(0, 0, 48, 48)],
        iconView = [[CPImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32, 32)];

    [iconView setCenter:[view center]];
    [iconView setImage:[imageViewIcon image]];
    [view setBackgroundColor:NUSkinColorGreyLighter];
    [view addSubview:iconView];
    [view setClipsToBounds:NO];

    [view setInAnimation:@"scaleIn" duration:0.15];
    view._DOMElement.style.borderRadius = "100px";
    view._DOMElement.style.border = "3px solid #5385D5";
    view._DOMElement.style.boxShadow = "0px 0px 10px gray";

    [view setCenter:[enclosingView center]];
    [enclosingView addSubview:view];
    [enclosingView setAlphaValue:0.9];

    return enclosingView;
}


#pragma mark -
#pragma mark CPCoding compliance

- (id)initWithCoder:(CPCoder)aCoder
{
    if (self = [super initWithCoder:aCoder])
    {
        fieldName        = [aCoder decodeObjectForKey:@"fieldName"];
        fieldDescription = [aCoder decodeObjectForKey:@"fieldDescription"];
        imageViewIcon    = [aCoder decodeObjectForKey:@"imageViewIcon"];
    }

    return self;
}

- (void)encodeWithCoder:(CPCoder)aCoder
{
    [super encodeWithCoder:aCoder];

    [aCoder encodeObject:fieldName forKey:@"fieldName"];
    [aCoder encodeObject:fieldDescription forKey:@"fieldDescription"];
    [aCoder encodeObject:imageViewIcon forKey:@"imageViewIcon"];
}

@end
